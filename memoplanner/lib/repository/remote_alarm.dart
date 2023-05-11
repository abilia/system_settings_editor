import 'dart:convert';

import 'package:http/http.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

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
    try {
      AlarmNavigator.log.info(
        'stoping alarm $alarm->${alarm.hashCode}',
      );
      final response = await client.post(
        '${baseUrlDb.baseUrl}/api/v1/push'.toUri(),
        headers: jsonHeader,
        body: jsonEncode(
          {
            if (pop) popKey: alarm.stackId,
            stopSoundKey: '${alarm.hashCode}',
          },
        ),
      );
      AlarmNavigator.log.info(
        'Remote alarm response: ${response.body} ${response.statusCode}',
      );
    } catch (error, stackTrace) {
      AlarmNavigator.log.fine('Could not stop remote alarm', error, stackTrace);
    }
  }
}
