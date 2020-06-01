import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final day = DateTime(2020, 05, 14);
  final activity = Activity.createNew(
      title: 'null', startTime: DateTime(2020, 06, 01, 17, 57));

  test('StartAlarm toPayload and back', () {
    final alarm = StartAlarm(activity, day);
    final payload = NotificationPayload.fromNotificationAlarm(alarm);
    final asJson = payload.toJson();

    final payloadAgain = NotificationPayload.fromJson(asJson);
    final back = payloadAgain.getAlarm(activity);
    expect(back, alarm);
  });
  test('EndAlarm toPayload and back', () {
    final alarm = EndAlarm(activity, day);
    final payload = NotificationPayload.fromNotificationAlarm(alarm);
    final asJson = payload.toJson();

    final payloadAgain = NotificationPayload.fromJson(asJson);
    final back = payloadAgain.getAlarm(activity);
    expect(back, alarm);
  });
  test('ReminderBefore toPayload and back', () {
    final alarm = ReminderBefore(activity, day, reminder: 15.minutes());
    final payload = NotificationPayload.fromNotificationAlarm(alarm);
    final asJson = payload.toJson();

    final payloadAgain = NotificationPayload.fromJson(asJson);
    final back = payloadAgain.getAlarm(activity);
    expect(back, alarm);
  });
  test('ReminderUnchecked toPayload and back', () {
    final alarm = ReminderUnchecked(activity, day, reminder: 15.minutes());
    final payload = NotificationPayload.fromNotificationAlarm(alarm);
    final asJson = payload.toJson();
    final payloadAgain = NotificationPayload.fromJson(asJson);
    final back = payloadAgain.getAlarm(activity);
    expect(back, alarm);
  });
}
