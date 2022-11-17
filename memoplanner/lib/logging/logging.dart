import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/utils/all.dart';

export 'package:logging/logging.dart';

enum LoggingType { file, print, crashReporting }

class SeagullLogger {
  File? _logFile;
  final _uploadLock = Lock();
  final _logFileLock = Lock();
  final Set<LoggingType> loggingType;
  List<StreamSubscription> loggingSubscriptions = [];
  final _log = Logger((SeagullLogger).toString());
  final String documentsDirectory;
  final SharedPreferences? preferences;

  late final bool fileLogging = loggingType.contains(LoggingType.file);
  late final bool printLogging = loggingType.contains(LoggingType.print);
  late final bool crashReporting =
      loggingType.contains(LoggingType.crashReporting);

  String get logFileName => '${Config.flavor.id}.log';

  factory SeagullLogger.test() => SeagullLogger(
        loggingType: const {LoggingType.print},
        documentsDirectory: '',
        level: Level.ALL,
      );

  factory SeagullLogger.nothing() => SeagullLogger(
        loggingType: const {},
        documentsDirectory: '',
        level: Level.OFF,
      );

  SeagullLogger({
    required this.documentsDirectory,
    this.preferences,
    this.loggingType = const {
      if (kDebugMode)
        LoggingType.print
      else ...{
        LoggingType.file,
        LoggingType.crashReporting,
      }
    },
    Level level = kDebugMode ? Level.ALL : Level.FINE,
  }) {
    if (loggingType.isNotEmpty) {
      Logger.root.level = level;
      if (fileLogging) _initFileLogging();
      if (printLogging) _initPrintLogging();
      if (crashReporting) _initCrashReporting();
    }
  }

  static const latestUploadKey = 'LATEST-LOG-UPLOAD-MILLIS';
  static const uploadInterval = Duration(hours: 24);
  static const logArchiveDirectory = 'logarchive';

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
              .subtract(uploadInterval)
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
      final logArchivePath = '$documentsDirectory/$logArchiveDirectory';
      final logArchiveDir = Directory(logArchivePath);
      await logArchiveDir.create(recursive: true);
      final archiveFilePath =
          '$logArchivePath/${Config.flavor.id}_log_$time.log';
      await _logFileLock.synchronized(() async {
        await _logFile?.copy(archiveFilePath);
        await _logFile?.writeAsString('');
      });

      final zipFile = File('$documentsDirectory/tmp_log_zip.zip');
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
          debugPrint(format(record));
          if (record.error != null) {
            debugPrint('${record.error}');
          }
          if (record.stackTrace != null) {
            debugPrint('${record.stackTrace}');
          }
        },
      ),
    );
  }

  void _initCrashReporting() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
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
    assert(documentsDirectory.isNotEmpty, 'documents dir empty');
    assert(preferences != null, 'preferences is null');
    _logFile = File('$documentsDirectory/$logFileName');
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
    if (printLogging && Platform.isAndroid) {
      final start = _logColor(record.level);
      const end = '\x1b[0m';
      return '$start${record.level.name}:$end ${record.time}: $start${record.loggerName}: ${record.message}$end';
    }
    return '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}';
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
      final lastUploadMillis = prefs.getInt(latestUploadKey);
      if (lastUploadMillis == null) {
        final now = DateTime.now();
        await prefs.setInt(latestUploadKey, now.millisecondsSinceEpoch);
        return now;
      }
      return DateTime.fromMillisecondsSinceEpoch(lastUploadMillis);
    }
    return DateTime.now();
  }

  Future<bool> _setLastUploadDateToNow() async {
    return await preferences?.setInt(
            latestUploadKey, DateTime.now().millisecondsSinceEpoch) ??
        false;
  }

  Future _writeToLogFile(String log) async {
    return await _logFileLock.synchronized(() async {
      return _logFile?.writeAsString(log, mode: FileMode.append);
    });
  }

  final _postLog = Logger('postLogFile');
  Future<bool> _postLogFile(
    File file,
  ) async {
    try {
      final prefs = preferences;
      if (prefs != null) {
        final user = UserDb(prefs).getUser();
        final bytes = await file.readAsBytes();
        final baseUrl = BaseUrlDb(prefs).baseUrl;

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
        _postLog.warning(
            'Could not save log file: ${streamedResponse.statusCode}, ${response.body}');
      }
    } catch (e) {
      _postLog.severe('Could not save log file.', e);
    }
    return false;
  }
}
