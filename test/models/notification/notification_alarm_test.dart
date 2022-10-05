import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final time = DateTime(2020, 05, 14, 18, 39, 30);
  final day = DateTime(2020, 05, 14);
  const timeZone = 'aTimeZone';

  test('StartAlarm toJson and back', () {
    final original = StartAlarm(
      ActivityDay(
        Activity.createNew(
          title: 'null',
          startTime: time,
          timezone: timeZone,
        ),
        day,
      ),
    );
    final asJson = original.toJson();
    final back = ActivityAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('EndAlarm toJson and back', () {
    final original = EndAlarm(
      ActivityDay(
        Activity.createNew(
          title: 'null',
          startTime: time,
          timezone: timeZone,
        ),
        day,
      ),
    );
    final asJson = original.toJson();
    final back = ActivityAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('ReminderBefore toJson and back', () {
    final original = ReminderBefore(
        ActivityDay(
          Activity.createNew(
            title: 'null',
            startTime: time,
            timezone: timeZone,
          ),
          day,
        ),
        reminder: const Duration(minutes: 5));
    final asJson = original.toJson();
    final back = ActivityAlarm.fromJson(asJson);
    expect(back, original);
  });
  test('ReminderUnchecked toJson and back', () {
    final original = ReminderUnchecked(
        ActivityDay(
          Activity.createNew(
            title: 'null',
            startTime: time,
            timezone: timeZone,
          ),
          day,
        ),
        reminder: const Duration(minutes: 5));
    final asJson = original.toJson();
    final back = ActivityAlarm.fromJson(asJson);
    expect(back, original);
  });

  group('payload', () {
    final day = DateTime(2020, 05, 14);
    final activity = Activity.createNew(
        title: 'null',
        startTime: DateTime(2020, 06, 01, 17, 57),
        timezone: timeZone);

    test('StartAlarm toPayload and back', () {
      final alarm = StartAlarm(ActivityDay(activity, day));
      final asJson = alarm.encode();

      final alarmAgain = NotificationAlarm.decode(asJson);
      expect(alarmAgain, alarm);
    });
    test('EndAlarm toPayload and back', () {
      final alarm = EndAlarm(ActivityDay(activity, day));
      final asJson = alarm.encode();

      final alarmAgain = NotificationAlarm.decode(asJson);
      expect(alarmAgain, alarm);
    });
    test('ReminderBefore toPayload and back', () {
      final alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: 15.minutes());
      final asJson = alarm.encode();

      final reminderAgain = NotificationAlarm.decode(asJson);
      expect(reminderAgain, alarm);
    });
    test('ReminderUnchecked toPayload and back', () {
      final alarm =
          ReminderUnchecked(ActivityDay(activity, day), reminder: 15.minutes());
      final asJson = alarm.encode();
      final reminderAgain = NotificationAlarm.decode(asJson);
      expect(reminderAgain, alarm);
    });
  });

  test('null default sound does return default', () {
    final nonCheckableAlarm = StartAlarm(
      ActivityDay(
        Activity.createNew(
          title: 'not checkable',
          startTime: DateTime(2021, 05, 12, 10, 27),
        ),
        day,
      ),
    );
    final checkableActivityAlarm = StartAlarm(
      ActivityDay(
          Activity.createNew(
            title: 'checkable',
            startTime: DateTime(2021, 05, 12, 10, 27),
            checkable: true,
          ),
          day),
    );
    const settings = AlarmSettings(
      checkableActivity: '',
      nonCheckableActivity: '',
    );
    expect(nonCheckableAlarm.sound(settings), Sound.Default);
    expect(checkableActivityAlarm.sound(settings), Sound.Default);
  });

  test(' Alarms from activityOccasion is same as from ActivityDay', () {
    final a = Activity.createNew(
      title: 'test',
      startTime: DateTime(2021, 11, 10, 13, 37),
    );
    final alarm = StartAlarm(ActivityDay(a, day));

    final activityOccasionAlarm = StartAlarm(
      ActivityOccasion(a, day, Occasion.current),
    );

    expect(alarm, activityOccasionAlarm);

    final reminder = ReminderUnchecked(ActivityDay(a, day),
        reminder: const Duration(minutes: 30));

    final activityOccasionReminder = ReminderUnchecked(
      ActivityOccasion(a, day, Occasion.current),
      reminder: const Duration(minutes: 30),
    );

    expect(reminder, activityOccasionReminder);
  });
}
