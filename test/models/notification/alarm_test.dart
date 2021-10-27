import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final time = DateTime(2020, 05, 14, 18, 39, 30);
  final day = DateTime(2020, 05, 14);
  const timeZone = 'aTimeZone';

  test('StartAlarm toJson and back', () {
    final original = StartAlarm(
        Activity.createNew(
          title: 'null',
          startTime: time,
          timezone: timeZone,
        ),
        day);
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('EndAlarm toJson and back', () {
    final original = EndAlarm(
        Activity.createNew(title: 'null', startTime: time, timezone: timeZone),
        day);
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('ReminderBefore toJson and back', () {
    final original = ReminderBefore(
        Activity.createNew(title: 'null', startTime: time, timezone: timeZone),
        day,
        reminder: const Duration(minutes: 5));
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('ReminderUnchecked toJson and back', () {
    final original = ReminderUnchecked(
        Activity.createNew(title: 'null', startTime: time, timezone: timeZone),
        day,
        reminder: const Duration(minutes: 5));
    final asJson = original.toJson();
    final back = NotificationAlarm.fromJson(asJson);
    expect(back, original);
  });

  group('payload', () {
    final day = DateTime(2020, 05, 14);
    final activity = Activity.createNew(
        title: 'null',
        startTime: DateTime(2020, 06, 01, 17, 57),
        timezone: timeZone);

    test('StartAlarm toPayload and back', () {
      final alarm = StartAlarm(activity, day);
      final asJson = alarm.encode();

      final alarmAgain = NotificationAlarm.decode(asJson);
      expect(alarmAgain, alarm);
    });
    test('EndAlarm toPayload and back', () {
      final alarm = EndAlarm(activity, day);
      final asJson = alarm.encode();

      final alarmAgain = NotificationAlarm.decode(asJson);
      expect(alarmAgain, alarm);
    });
    test('ReminderBefore toPayload and back', () {
      final alarm = ReminderBefore(activity, day, reminder: 15.minutes());
      final asJson = alarm.encode();

      final reminderAgain = NotificationAlarm.decode(asJson);
      expect(reminderAgain, alarm);
    });
    test('ReminderUnchecked toPayload and back', () {
      final alarm = ReminderUnchecked(activity, day, reminder: 15.minutes());
      final asJson = alarm.encode();
      final reminderAgain = NotificationAlarm.decode(asJson);
      expect(reminderAgain, alarm);
    });
  });

  test('null default sound does return default', () {
    final nonCheckableAlarm = StartAlarm(
        Activity.createNew(
          title: 'not checkable',
          startTime: DateTime(2021, 05, 12, 10, 27),
        ),
        day);
    final checkableActivityAlarm = StartAlarm(
        Activity.createNew(
          title: 'checkable',
          startTime: DateTime(2021, 05, 12, 10, 27),
          checkable: true,
        ),
        day);
    const settings = AlarmSettings(
      checkableActivity: '',
      nonCheckableActivity: '',
    );
    expect(nonCheckableAlarm.sound(settings), Sound.Default);
    expect(checkableActivityAlarm.sound(settings), Sound.Default);
  });
}
