import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:intl/intl.dart';

export 'package:logging/logging.dart';

enum LoggingType { File, Print, Analytic }

class SeagullLogger {
  final UserDb userDb;
  File _logFile;
  final _uploadLock = Lock();
  final _logFileLock = Lock();
  final Set<LoggingType> loggingType;
  List<StreamSubscription> loggingSubscriptions = [];
  final _log = Logger((SeagullLogger).toString());

  bool get fileLogging => loggingType.contains(LoggingType.File);
  bool get printLogging => loggingType.contains(LoggingType.Print);
  bool get analyticLogging => loggingType.contains(LoggingType.Analytic);

  SeagullLogger({
    this.userDb,
    this.loggingType = const {
      if (kReleaseMode) ...{
        LoggingType.File,
        LoggingType.Analytic,
      } else
        LoggingType.Print
    },
  });

  static const LATEST_UPLOAD_KEY = 'LATEST-LOG-UPLOAD-MILLIS';
  static const UPLOAD_INTERVAL = Duration(hours: 24);
  static const LOG_FILE_NAME = 'seagull.log';
  static const LOG_ARCHIVE_PATH = 'logarchive';

  Future<void> initLogging({
    bool initAnalitics = kReleaseMode,
    Level level = kReleaseMode ? Level.FINE : Level.ALL,
  }) async {
    if (initAnalitics) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      final appId = 'e0cb99ae-de4a-4bf6-bc91-ccd7d843f5ed';
      await AppCenter.startAsync(
        appSecretAndroid: appId,
        appSecretIOS: appId,
      );
      await AppCenter.configureDistributeDebugAsync(enabled: false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    Bloc.observer = BlocLoggingObserver();
    Logger.root.level = level;

    if (fileLogging) {
      await _initFileLogging();
    }
    if (printLogging) {
      _initPrintLogging();
    }
    if (analyticLogging) {
      _initAnalyticsLogging();
    }
  }

  Future<void> cancelLogging() async {
    if (loggingSubscriptions.isNotEmpty) {
      await loggingSubscriptions.forEach(
        (loggingSubscription) => loggingSubscription.cancel(),
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
      final logArchiveDir = Directory(await _logArchivePath);
      await logArchiveDir.create(recursive: true);
      final archiveFilePath = '${await _logArchivePath}/seagull_log_$time.log';
      await _logFileLock.synchronized(() async {
        await _logFile.copy(archiveFilePath);
        await _logFile.writeAsString('');
      });

      final zipFile = File('${await _documentsDir}/tmp_log_zip.zip');
      await ZipFile.createFromDirectory(
          sourceDir: logArchiveDir, zipFile: zipFile, recurseSubDirs: true);
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
          print(
              '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
          if (record?.error != null) {
            print(record.error);
          }
          if (record?.stackTrace != null) {
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
            final message =
                '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}';
            if (record?.error != null) {
              FirebaseCrashlytics.instance.recordError(
                record.error,
                record.stackTrace,
                reason: message,
              );
            } else {
              FirebaseCrashlytics.instance.log(message);
            }
          }
        },
      ),
    );
  }

  Future<void> _initFileLogging() async {
    final path = await _documentsDir;
    _logFile = File('$path/$LOG_FILE_NAME');

    loggingSubscriptions.add(
      Logger.root.onRecord.listen(
        (record) async {
          final stringBuffer = StringBuffer();
          stringBuffer.writeln(
              '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
          if (record?.error != null) {
            stringBuffer.writeln(record.error);
          }
          if (record?.stackTrace != null) {
            stringBuffer.writeln(record.stackTrace);
          }
          await _writeToLogFile(stringBuffer.toString());
        },
      ),
    );
  }

  Future<DateTime> _getLastUploadDate() async {
    final preferences = await SharedPreferences.getInstance();
    final lastUploadMillis = preferences.getInt(LATEST_UPLOAD_KEY);
    if (lastUploadMillis == null) {
      final now = DateTime.now();
      await preferences.setInt(LATEST_UPLOAD_KEY, now.millisecondsSinceEpoch);
      return now;
    } else {
      return DateTime.fromMillisecondsSinceEpoch(lastUploadMillis);
    }
  }

  Future<bool> _setLastUploadDateToNow() async {
    final preferences = await SharedPreferences.getInstance();
    return await preferences.setInt(
        LATEST_UPLOAD_KEY, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String> get _documentsDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _logArchivePath async {
    return '${await _documentsDir}/$LOG_ARCHIVE_PATH';
  }

  Future<File> _writeToLogFile(String log) async {
    return await _logFileLock.synchronized(() async {
      return _logFile.writeAsString('$log', mode: FileMode.append);
    });
  }

  Future<bool> _postLogFile(
    File file,
  ) async {
    final _log = Logger('postLogFile');
    try {
      final user = await userDb.getUser();
      final bytes = await file.readAsBytes();
      final baseUrl = await BaseUrlDb().getBaseUrl();

      final uri = Uri.parse('$baseUrl/open/v1/logs/');
      final request = MultipartRequest('POST', uri)
        ..files.add(MultipartFile.fromBytes(
          'file',
          bytes,
          filename:
              'test.log', // Weird but backend doesn't accept request without filename.
        ))
        ..fields.addAll({
          'owner': user == null ? 'NO_USER' : user.id.toString(),
          'app': 'seagull',
          'fileType': 'zip',
          'secret': 'Mkediq9Jjdn23jKfnKpqmfhkfjMfj',
        });

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        return true;
      } else {
        final response = await Response.fromStream(streamedResponse);
        _log.warning(
            'Could not save log file: ${streamedResponse.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      _log.severe('Could not save log file.', e);
      return false;
    }
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
  final _loggers = <Bloc, Logger>{};
  Logger _log(Bloc bloc) =>
      _loggers[bloc] ??= Logger(bloc.runtimeType.toString());
  @override
  void onEvent(Bloc bloc, Object event) {
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
    await logEventToAnalytics(transition);
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
  void onError(Cubit cubit, Object error, StackTrace stacktrace) {
    super.onError(cubit, error, stacktrace);
    _log(cubit).severe('error in $cubit', error, stacktrace);
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
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _log.fine('didPush $route');
      _log.finest('didPush previousRoute $previousRoute');
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _log.fine('didReplace $newRoute');
      _log.finest('didReplace oldRoute $oldRoute');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _log.fine('didPop $route');
      _log.finest('didPop previousRoute $previousRoute');
    }
  }
}
