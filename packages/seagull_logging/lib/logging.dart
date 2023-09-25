import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:utils/string_extensions.dart';

export 'package:logging/logging.dart';

class SeagullLogger {
  File? _logFile;
  final _uploadLock = Lock();
  final _logFileLock = Lock();
  final String app;
  final bool printLogging;
  final List<StreamSubscription> loggingSubscriptions = [];
  final _log = Logger((SeagullLogger).toString());
  final String documentsDirectory;
  final SharedPreferences? preferences;
  final String supportId;

  String get logFileName => '$app.log';

  factory SeagullLogger.empty() => SeagullLogger(
        documentsDirectory: '',
        supportId: '',
        level: Level.OFF,
        app: '',
      );

  SeagullLogger({
    required this.documentsDirectory,
    required this.supportId,
    required this.app,
    this.preferences,
    this.printLogging = kDebugMode,
    Level level = kDebugMode ? Level.ALL : Level.FINE,
  }) {
    Logger.root.level = level;
    if (printLogging) {
      _initPrintLogging();
    } else {
      _initFileLogging();
      _initCrashReporting();
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
    if (printLogging) return;
    await _uploadLock.synchronized(
      () async {
        final lastUpload = _getLastUploadTimeStamp();
        if (lastUpload == null) return _setLastUploadAttemptToNow();

        final now = DateTime.now().millisecondsSinceEpoch;
        final intervalPassed = now - lastUpload > uploadInterval.inMilliseconds;
        if (intervalPassed) {
          await uploadLogsToBackend();
        }
      },
    );
  }

  Future<void> uploadLogsToBackend() async {
    if (printLogging) return;
    _log.info('Uploading logs to backend');
    final time = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
    final logArchivePath = '$documentsDirectory/$logArchiveDirectory';
    final logArchiveDir = Directory(logArchivePath);
    await logArchiveDir.create(recursive: true);
    final archiveFilePath = '$logArchivePath/${app}_log_$time.log';
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
      await logArchiveDir.delete(recursive: true);
    }
    await _setLastUploadAttemptToNow();
    await zipFile.delete();
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
        (record) async {
          if (record.level > Level.WARNING && record.error != null) {
            return FirebaseCrashlytics.instance.recordError(
              record.error,
              record.stackTrace,
              reason: format(record),
            );
          }
          await FirebaseCrashlytics.instance.log(format(record));
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
          final stringBuffer = StringBuffer()..writeln(format(record));
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

  int? _getLastUploadTimeStamp() => preferences?.getInt(latestUploadKey);

  Future<void> _setLastUploadAttemptToNow() async {
    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    await preferences?.setInt(latestUploadKey, millisecondsSinceEpoch);
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
            'owner': supportId,
            'app': app,
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
