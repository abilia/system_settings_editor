import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCanceler {
  static const cancelAlarmKey = 'cancelAlarm';
  final BaseUrlDb baseUrlDb;
  final BaseClient client;
  final FlutterLocalNotificationsPlugin notificationPlugin;

  AlarmCanceler({
    required this.client,
    required this.baseUrlDb,
    required this.notificationPlugin,
  });

  Future<void> stopAlarmSound(NotificationAlarm alarm) async {
    await notificationPlugin.cancel(alarm.hashCode);
    await client.post(
      '${baseUrlDb.baseUrl}/api/v1/push'.toUri(),
      headers: jsonHeader,
      body: jsonEncode({cancelAlarmKey: alarm.hashCode}),
    );
  }
}
