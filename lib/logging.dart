import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:bloc/bloc.dart';

import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/all.dart';

export 'package:logging/logging.dart';

// ignore_for_file: avoid_print

enum LoggingType { File, Print, Analytic }

class SeagullLogger {
  File? _logFile;
  final _uploadLock = Lock();
  final _logFileLock = Lock();
  final Set<LoggingType> loggingType;
  List<StreamSubscription> loggingSubscriptions = [];
  final _log = Logger((SeagullLogger).toString());
  final String documentsDir;
  final SharedPreferences? preferences;

  bool get fileLogging => loggingType.contains(LoggingType.File);
  bool get printLogging => loggingType.contains(LoggingType.Print);
  bool get analyticLogging => loggingType.contains(LoggingType.Analytic);

  String get logFileName => '${Config.flavor.id}.log';

  factory SeagullLogger.test() => SeagullLogger(
        loggingType: const {LoggingType.Print},
        documentsDir: '',
        level: Level.ALL,
      );

  factory SeagullLogger.nothing() => SeagullLogger(
        loggingType: const {},
        documentsDir: '',
      );

  SeagullLogger({
    required this.documentsDir,
    this.preferences,
    this.loggingType = const {
      if (Config.release) ...{
        LoggingType.File,
        LoggingType.Analytic,
      } else
        LoggingType.Print,
    },
    Level level = Config.release ? Level.FINE : Level.ALL,
  }) {
    if (loggingType.isNotEmpty) {
      Bloc.observer = BlocLoggingObserver(analyticsLogging: analyticLogging);
      Logger.root.level = level;
      if (fileLogging) _initFileLogging();
      if (printLogging) _initPrintLogging();
      if (analyticLogging) _initAnalyticsLogging();
    }
  }

  static const LATEST_UPLOAD_KEY = 'LATEST-LOG-UPLOAD-MILLIS';
  static const UPLOAD_INTERVAL = Duration(hours: 24);
  static const LOG_ARCHIVE_PATH = 'logarchive';

  Future<void> initAnalytics() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  Future<void> cancelLogging() async {
    if (loggingSubscriptions.isNotEmpty) {
      await Future.wait(
        loggingSubscriptions.map(
          (loggingSubscription) => loggingSubscription.cancel(),
        ),
      );
    }
  }

  Future<void> maybeUploadLogs() async {
    if (fileLogging) {
      await _uploadLock.synchronized(
        () async {
          if (DateTime.now()
              .subtract(UPLOAD_INTERVAL)
              .isAfter(await _getLastUploadDate())) {
            _log.info('Time to upload logs to backend');
            await sendLogsToBackend();
          }
        },
      );
    }
  }

  Future<void> sendLogsToBackend() async {
    if (fileLogging) {
      final time = DateFormat('yyyyMMddHHmm').format(DateTime.now());
      final _logArchivePath = '$documentsDir/$LOG_ARCHIVE_PATH';
      final logArchiveDir = Directory(_logArchivePath);
      await logArchiveDir.create(recursive: true);
      final archiveFilePath =
          '$_logArchivePath/${Config.flavor.id}_log_$time.log';
      await _logFileLock.synchronized(() async {
        await _logFile?.copy(archiveFilePath);
        await _logFile?.writeAsString('');
      });

      final zipFile = File('$documentsDir/tmp_log_zip.zip');
      await ZipFile.createFromDirectory(
        sourceDir: logArchiveDir,
        zipFile: zipFile,
        recurseSubDirs: true,
      );
      final uploadSuccess = await _postLogFile(zipFile);
      if (uploadSuccess) {
        await _setLastUploadDateToNow();
        await logArchiveDir.delete(recursive: true);
      }
      await zipFile.delete();
    }
  }

  void _initPrintLogging() {
    loggingSubscriptions.add(
      Logger.root.onRecord.listen(
        (record) {
          print(format(record));
          if (record.error != null) {
            print(record.error);
          }
          if (record.stackTrace != null) {
            print(record.stackTrace);
          }
        },
      ),
    );
  }

  void _initAnalyticsLogging() {
    loggingSubscriptions.add(
      Logger.root.onRecord.listen(
        (record) {
          if (record.level > Level.WARNING) {
            if (record.error != null) {
              FirebaseCrashlytics.instance.recordError(
                record.error,
                record.stackTrace,
                reason: format(record),
              );
            } else {
              FirebaseCrashlytics.instance.log(format(record));
            }
          }
        },
      ),
    );
  }

  void _initFileLogging() {
    assert(documentsDir.isNotEmpty, 'documents dir empty');
    assert(preferences != null, 'preferences is null');
    _logFile = File('$documentsDir/$logFileName');
    loggingSubscriptions.add(
      Logger.root.onRecord.listen(
        (record) async {
          final stringBuffer = StringBuffer();
          stringBuffer.writeln(format(record));
          if (record.error != null) {
            stringBuffer.writeln(record.error);
          }
          if (record.stackTrace != null) {
            stringBuffer.writeln(record.stackTrace);
          }
          await _writeToLogFile(stringBuffer.toString());
        },
      ),
    );
  }

  String format(LogRecord record) {
    if (Platform.isIOS) {
      return '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}';
    }
    final start = _logColor(record.level);
    const end = '\x1b[0m';
    return '$start${record.level.name}:$end ${record.time}: $start${record.loggerName}: ${record.message}$end';
  }

  String _logColor(Level level) {
    switch (level.name) {
      case 'INFO':
        return '\x1b[37m';
      case 'WARNING':
        return '\x1b[93m';
      case 'SEVERE':
        return '\x1b[103m\x1b[31m';
      case 'SHOUT':
        return '\x1b[41m\x1b[93m';
      default:
        return '\x1b[90m';
    }
  }

  Future<DateTime> _getLastUploadDate() async {
    final prefs = preferences;
    if (prefs != null) {
      final lastUploadMillis = prefs.getInt(LATEST_UPLOAD_KEY);
      if (lastUploadMillis == null) {
        final now = DateTime.now();
        await prefs.setInt(LATEST_UPLOAD_KEY, now.millisecondsSinceEpoch);
        return now;
      }
      return DateTime.fromMillisecondsSinceEpoch(lastUploadMillis);
    }
    return DateTime.now();
  }

  Future<bool> _setLastUploadDateToNow() async {
    return await preferences?.setInt(
            LATEST_UPLOAD_KEY, DateTime.now().millisecondsSinceEpoch) ??
        false;
  }

  Future _writeToLogFile(String log) async {
    return await _logFileLock.synchronized(() async {
      return _logFile?.writeAsString(log, mode: FileMode.append);
    });
  }

  Future<bool> _postLogFile(
    File file,
  ) async {
    final _log = Logger('postLogFile');
    try {
      final prefs = preferences;
      if (prefs != null) {
        final user = UserDb(prefs).getUser();
        final bytes = await file.readAsBytes();
        final baseUrl = BaseUrlDb(prefs).getBaseUrl();

        final uri = '$baseUrl/open/v1/logs/'.toUri();
        final request = MultipartRequest('POST', uri)
          ..files.add(MultipartFile.fromBytes(
            'file',
            bytes,
            filename:
                'test.log', // Weird but backend doesn't accept request without filename.
          ))
          ..fields.addAll({
            'owner': user == null ? 'NO_USER' : user.id.toString(),
            'app': Config.flavor.id,
            'fileType': 'zip',
            'secret': 'Mkediq9Jjdn23jKfnKpqmfhkfjMfj',
          });

        final streamedResponse = await request.send();
        if (streamedResponse.statusCode == 200) {
          return true;
        }
        final response = await Response.fromStream(streamedResponse);
        _log.warning(
            'Could not save log file: ${streamedResponse.statusCode}, ${response.body}');
      }
    } catch (e) {
      _log.severe('Could not save log file.', e);
    }
    return false;
  }
}

mixin Silent {}
mixin Finest {}
mixin Finer implements Finest {}
mixin Fine implements Finer {}
mixin Info implements Fine {}
mixin Warning implements Info {}
mixin Shout implements Warning {}

class BlocLoggingObserver extends BlocObserver {
  BlocLoggingObserver({this.analyticsLogging = false});

  final bool analyticsLogging;
  final _loggers = <BlocBase, Logger>{};

  Logger _log(BlocBase bloc) =>
      _loggers[bloc] ??= Logger(bloc.runtimeType.toString());
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is Silent || bloc is Silent) return;
    final log = _log(bloc);
    if (event is Shout) {
      log.shout(event);
    } else if (event is Warning) {
      log.warning(event);
    } else if (event is Info) {
      log.info(event);
    } else if (event is Fine) {
      log.fine(event);
    } else if (event is Finest) {
      log.finest(event);
    } else {
      log.finer(event);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    super.onTransition(bloc, transition);
    if (analyticsLogging) logEventToAnalytics(transition);
    final event = transition.event;
    if (event is Silent || bloc is Silent) return;
    final log = _log(bloc);
    if (bloc is Shout) {
      log.shout(transition);
    } else if (bloc is Warning) {
      log.warning(transition);
    } else if (bloc is Info) {
      log.info(transition);
    } else if (bloc is Fine) {
      log.fine(transition);
    } else if (bloc is Finest) {
      log.finest(transition);
    } else {
      log.finer(transition);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _log(bloc).severe('error in $bloc', error, stackTrace);
  }

  void logEventToAnalytics(Transition transition) async {
    final event = transition.event;
    final nextState = transition.nextState;
    if (event is AddActivity) {
      await AnalyticsService.sendActivityCreatedEvent(event.activity);
    }
    if (event is LoggedIn) {
      await AnalyticsService.sendLoginEvent();
    }
    if (nextState is Authenticated) {
      await AnalyticsService.setUserId(nextState.userId);
    }
  }
}

class RouteLoggingObserver extends RouteObserver<PageRoute<dynamic>> {
  final _log = Logger('RouteLogger');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _log.fine('didPush $route');
      _log.finest('didPush previousRoute $previousRoute');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _log.fine('didReplace $newRoute');
      _log.finest('didReplace oldRoute $oldRoute');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _log.fine('didPop $route');
      _log.finest('didPop previousRoute $previousRoute');
    }
  }
}
