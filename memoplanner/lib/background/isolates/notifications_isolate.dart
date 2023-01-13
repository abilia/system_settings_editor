import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/timezone.dart';

FlutterIsolate? alarmSchedulerIsolate;

NotificationsScheduler scheduleNotificationsIsolated =
    (NotificationsSchedulerData schedulerData) async {
  final sendPortCompleter = Completer<SendPort>();
  final isolateCompleter = Completer();
  final ReceivePort receivePort = ReceivePort();
  final log = Logger('NotificationsIsolate');

  alarmSchedulerIsolate?.kill();
  alarmSchedulerIsolate = await _scheduleNotificationsIsolated(receivePort);

  receivePort.listen((message) {
    if (message is SendPort) {
      return sendPortCompleter.complete(message);
    } else if (message is Map<String, dynamic>) {
      return log.log(_level(message['level']), message['message']);
    }
    return isolateCompleter.complete();
  });

  final sendPort = await sendPortCompleter.future;
  sendPort.send(schedulerData.toMap());

  await isolateCompleter.future;
};

Future<FlutterIsolate?> _scheduleNotificationsIsolated(
    ReceivePort receivePort) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return FlutterIsolate.spawn(_scheduleNotifications, receivePort.sendPort);
  }
  _scheduleNotifications(receivePort.sendPort);
  return null;
}

@pragma('vm:entry-point')
void _scheduleNotifications(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is Map<String, dynamic>) {
      await configureLocalTimeZone();
      final schedulerData = NotificationsSchedulerData.fromMap(message);
      await scheduleNotifications(
        schedulerData,
        (logLevel, message, [error, stackTrace, zone]) => sendPort.send(
          {
            'level': logLevel.value,
            'message': message,
          },
        ),
      );
      sendPort.send(true);
    }
  });
}

Level _level(level) {
  if (level is int) {
    if (level <= Level.FINEST.value) return Level.FINEST;
    if (level <= Level.FINER.value) return Level.FINER;
    if (level <= Level.FINE.value) return Level.FINE;
    if (level <= Level.CONFIG.value) return Level.CONFIG;
    if (level <= Level.INFO.value) return Level.INFO;
    if (level <= Level.WARNING.value) return Level.WARNING;
    if (level <= Level.SEVERE.value) return Level.SEVERE;
    if (level <= Level.SHOUT.value) return Level.SHOUT;
  }
  return Level.INFO;
}
