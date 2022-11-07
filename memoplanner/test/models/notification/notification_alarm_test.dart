import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

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

  group('Vibration', () {
    final day = DateTime(2020, 05, 14);
    final startActivity = Activity.createNew(
      title: 'null',
      startTime: DateTime(2020, 06, 01, 17, 57),
      timezone: timeZone,
    );
    final timer = AbiliaTimer(
      id: 'id',
      startTime: day,
      duration: Duration.zero,
    );

    test(
        'nonCheckableActivity has vibration when AlarmType is vibration or soundAndVibration',
        () {
      // Arrange - Default sound with vibration
      AlarmSettings alarmSettings =
          AlarmSettings(nonCheckableActivity: Sound.Default.name);
      Activity activity = startActivity.copyWith(alarmType: alarmVibration);
      StartAlarm alarm = StartAlarm(ActivityDay(activity, day));
      bool hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with vibration
      alarmSettings = AlarmSettings(nonCheckableActivity: Sound.NoSound.name);
      activity = startActivity.copyWith(alarmType: alarmVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound
      alarmSettings = AlarmSettings(nonCheckableActivity: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: alarmSound);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - Default sound with no alarm
      alarmSettings = AlarmSettings(nonCheckableActivity: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: noAlarm);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);
    });

    test(
        'checkableActivity has vibration when AlarmType is vibration or soundAndVibration',
        () {
      // Arrange - Default sound with vibration
      AlarmSettings alarmSettings =
          AlarmSettings(checkableActivity: Sound.Default.name);
      Activity activity = startActivity.copyWith(alarmType: alarmVibration);
      StartAlarm alarm = StartAlarm(ActivityDay(activity, day));
      bool hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with vibration
      alarmSettings = AlarmSettings(checkableActivity: Sound.NoSound.name);
      activity = startActivity.copyWith(alarmType: alarmVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound
      alarmSettings = AlarmSettings(checkableActivity: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: alarmSound);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - Default sound with no alarm
      alarmSettings = AlarmSettings(checkableActivity: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: noAlarm);
      alarm = StartAlarm(ActivityDay(activity, day));
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);
    });

    test('reminders has vibration when have a sound', () {
      // Arrange - Default sound with vibration
      AlarmSettings alarmSettings = AlarmSettings(reminder: Sound.Default.name);
      Activity activity = startActivity.copyWith(alarmType: alarmVibration);
      ReminderBefore alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      bool hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with vibration
      alarmSettings = AlarmSettings(reminder: Sound.NoSound.name);
      activity = startActivity.copyWith(alarmType: alarmVibration);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - No sound with sound and vibration
      activity = startActivity.copyWith(alarmType: alarmSoundAndVibration);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - Default sound with sound
      alarmSettings = AlarmSettings(reminder: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: alarmSound);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with no alarm
      alarmSettings = AlarmSettings(reminder: Sound.Default.name);
      activity = startActivity.copyWith(alarmType: noAlarm);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with no alarm
      alarmSettings = AlarmSettings(reminder: Sound.NoSound.name);
      activity = startActivity.copyWith(alarmType: noAlarm);
      alarm =
          ReminderBefore(ActivityDay(activity, day), reminder: Duration.zero);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);
    });

    test('timers has vibration when have a sound', () {
      // Arrange - Default sound with vibration
      AlarmSettings alarmSettings = AlarmSettings(timer: Sound.Default.name);
      TimerAlarm alarm = TimerAlarm(timer);
      bool hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with sound and vibration
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with vibration
      alarmSettings = AlarmSettings(timer: Sound.NoSound.name);
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - No sound with sound and vibration
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);

      // Arrange - Default sound with sound
      alarmSettings = AlarmSettings(timer: Sound.Default.name);
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - Default sound with no alarm
      alarmSettings = AlarmSettings(timer: Sound.Default.name);
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, true);

      // Arrange - No sound with no alarm
      alarmSettings = AlarmSettings(timer: Sound.NoSound.name);
      alarm = TimerAlarm(timer);
      hasVibration = alarm.hasVibration(alarmSettings);
      expect(hasVibration, false);
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
