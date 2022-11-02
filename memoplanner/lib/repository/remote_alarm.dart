import 'dart:convert';

import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class RemoteAlarm {
  static const stopSoundKey = 'cancelAlarmSound', popKey = 'popAlarm';
  final BaseUrlDb baseUrlDb;
  final BaseClient client;

  RemoteAlarm({required this.client, required this.baseUrlDb});

  Future<void> stop(
    NotificationAlarm alarm, {
    bool pop = false,
  }) async {
    if (alarm is TimerAlarm) return;
    await client.post(
      '${baseUrlDb.baseUrl}/api/v1/push'.toUri(),
      headers: jsonHeader,
      body: jsonEncode(
        {
          if (pop) popKey: alarm.stackId,
          stopSoundKey: alarm.hashCode,
        },
      ),
    );
  }
}
