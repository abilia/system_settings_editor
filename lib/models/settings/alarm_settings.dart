import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class AlarmSettings extends Equatable {
  static const nonCheckableActivityAlarmKey = 'activity_alarm_without_confirm',
      checkableActivityAlarmKey = 'activity_alarm_with_confirm',
      reminderAlarmKey = 'activity_reminder_alarm',
      vibrateAtReminderKey = 'setting_vibrate_at_reminder',
      alarmDurationKey = 'alarm_duration',
      alarmsDisabledUntilKey = 'alarms_disabled_until';

  static const keys = [
    nonCheckableActivityAlarmKey,
    checkableActivityAlarmKey,
    reminderAlarmKey,
    vibrateAtReminderKey,
    alarmDurationKey,
    alarmsDisabledUntilKey,
  ];

  final int duration, disabledUntilEpoch;
  final bool vibrateAtReminder;

  final String checkableActivity, nonCheckableActivity, reminder;
  Sound get nonCheckableAlarm => nonCheckableActivity.toSound();
  Sound get checkableAlarm => checkableActivity.toSound();
  Sound get reminderAlarm => reminder.toSound();
  DateTime get disabledUntilDate =>
      DateTime.fromMillisecondsSinceEpoch(disabledUntilEpoch);
  const AlarmSettings({
    this.duration = 30000,
    this.vibrateAtReminder = true,
    this.checkableActivity = SoundExtension.defaultName,
    this.nonCheckableActivity = SoundExtension.defaultName,
    this.reminder = SoundExtension.defaultName,
    this.disabledUntilEpoch = 0,
  });

  factory AlarmSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      AlarmSettings(
        duration: settings.parse(
          alarmDurationKey,
          30000,
        ),
        checkableActivity: settings.parse(
          checkableActivityAlarmKey,
          Sound.Default.name(),
        ),
        nonCheckableActivity: settings.parse(
          nonCheckableActivityAlarmKey,
          Sound.Default.name(),
        ),
        reminder: settings.parse(
          reminderAlarmKey,
          Sound.Default.name(),
        ),
        vibrateAtReminder: settings.getBool(
          vibrateAtReminderKey,
          defaultValue: true,
        ),
        disabledUntilEpoch: settings.parse(
          alarmsDisabledUntilKey,
          0,
        ),
      );

  @override
  List<Object?> get props => [
        duration,
        vibrateAtReminder,
        checkableActivity,
        nonCheckableActivity,
        reminder,
        disabledUntilEpoch,
      ];
}
