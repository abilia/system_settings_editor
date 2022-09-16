import 'package:equatable/equatable.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';

class AlarmSettings extends Equatable {
  Sound get nonCheckableSound => nonCheckableActivity.toSound();
  Sound get checkableSound => checkableActivity.toSound();
  Sound get reminderSound => reminder.toSound();
  Sound get timerSound => timer.toSound();
  AlarmDuration get alarmDuration => durationMs.toAlarmDuration();
  bool get showOngoingActivityInFullScreen =>
      Config.isMP && _showOngoingActivityInFullScreen;

  static const nonCheckableActivityAlarmKey = 'activity_alarm_without_confirm',
      checkableActivityAlarmKey = 'activity_alarm_with_confirm',
      reminderAlarmKey = 'activity_reminder_alarm',
      timerAlarmKey = 'activity_timer_alarm',
      vibrateAtReminderKey = 'setting_vibrate_at_reminder',
      alarmDurationKey = 'alarm_duration',
      alarmsDisabledUntilKey = 'alarms_disabled_until',
      showAlarmOnOffSwitchKey = 'show_alarms_button',
      showOngoingActivityInFullScreenKey =
          'setting_show_activity_in_full_screen';

  static const keys = [
    nonCheckableActivityAlarmKey,
    checkableActivityAlarmKey,
    reminderAlarmKey,
    timerAlarmKey,
    vibrateAtReminderKey,
    alarmDurationKey,
    alarmsDisabledUntilKey,
    showAlarmOnOffSwitchKey,
    showOngoingActivityInFullScreenKey,
  ];

  final int durationMs, disabledUntilEpoch;
  final bool vibrateAtReminder,
      showAlarmOnOffSwitch,
      _showOngoingActivityInFullScreen;

  final String checkableActivity, nonCheckableActivity, reminder, timer;

  Sound get nonCheckableAlarm => nonCheckableActivity.toSound();

  Sound get checkableAlarm => checkableActivity.toSound();

  Sound get reminderAlarm => reminder.toSound();

  Sound get timerAlarm => timer.toSound();

  Duration get duration => Duration(milliseconds: durationMs);

  DateTime get disabledUntilDate =>
      DateTime.fromMillisecondsSinceEpoch(disabledUntilEpoch);

  const AlarmSettings({
    this.durationMs = 30000,
    this.vibrateAtReminder = true,
    this.checkableActivity = SoundExtension.defaultName,
    this.nonCheckableActivity = SoundExtension.defaultName,
    this.reminder = SoundExtension.defaultName,
    this.timer = SoundExtension.defaultName,
    this.disabledUntilEpoch = 0,
    this.showAlarmOnOffSwitch = false,
    bool showOngoingActivityInFullScreen = false,
  }) : _showOngoingActivityInFullScreen = showOngoingActivityInFullScreen;

  AlarmSettings copyWith({
    Sound? nonCheckableSound,
    Sound? checkableSound,
    Sound? reminderSound,
    Sound? timerSound,
    bool? vibrateAtReminder,
    AlarmDuration? alarmDuration,
    bool? showAlarmOnOffSwitch,
    bool? showOngoingActivityInFullScreen,
  }) =>
      AlarmSettings(
        durationMs: alarmDuration?.milliseconds() ?? durationMs,
        nonCheckableActivity: nonCheckableSound?.name ?? nonCheckableActivity,
        checkableActivity: checkableSound?.name ?? checkableActivity,
        reminder: reminderSound?.name ?? reminder,
        vibrateAtReminder: vibrateAtReminder ?? this.vibrateAtReminder,
        timer: timerSound?.name ?? timer,
        showAlarmOnOffSwitch: showAlarmOnOffSwitch ?? this.showAlarmOnOffSwitch,
        showOngoingActivityInFullScreen:
            showOngoingActivityInFullScreen ?? _showOngoingActivityInFullScreen,
      );

  factory AlarmSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      AlarmSettings(
        durationMs: settings.parse(
          alarmDurationKey,
          30000,
        ),
        checkableActivity: settings.parse(
          checkableActivityAlarmKey,
          Sound.Default.name,
        ),
        nonCheckableActivity: settings.parse(
          nonCheckableActivityAlarmKey,
          Sound.Default.name,
        ),
        reminder: settings.parse(
          reminderAlarmKey,
          Sound.Default.name,
        ),
        timer: settings.parse(
          timerAlarmKey,
          Sound.Default.name,
        ),
        vibrateAtReminder: settings.getBool(
          vibrateAtReminderKey,
          defaultValue: true,
        ),
        disabledUntilEpoch: settings.parse(
          alarmsDisabledUntilKey,
          0,
        ),
        showAlarmOnOffSwitch: settings.getBool(
          showAlarmOnOffSwitchKey,
          defaultValue: false,
        ),
        showOngoingActivityInFullScreen: settings.getBool(
          showOngoingActivityInFullScreenKey,
          defaultValue: false,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: nonCheckableSound.name,
          identifier: AlarmSettings.nonCheckableActivityAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: checkableSound.name,
          identifier: AlarmSettings.checkableActivityAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: reminderSound.name,
          identifier: AlarmSettings.reminderAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: timerSound.name,
          identifier: AlarmSettings.timerAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: vibrateAtReminder,
          identifier: AlarmSettings.vibrateAtReminderKey,
        ),
        MemoplannerSettingData.fromData(
          data: alarmDuration.milliseconds(),
          identifier: AlarmSettings.alarmDurationKey,
        ),
        MemoplannerSettingData.fromData(
          data: showAlarmOnOffSwitch,
          identifier: AlarmSettings.showAlarmOnOffSwitchKey,
        ),
        MemoplannerSettingData.fromData(
          data: _showOngoingActivityInFullScreen,
          identifier: AlarmSettings.showOngoingActivityInFullScreenKey,
        )
      ];

  @override
  List<Object?> get props => [
        duration,
        vibrateAtReminder,
        checkableActivity,
        nonCheckableActivity,
        reminder,
        timer,
        disabledUntilEpoch,
        showAlarmOnOffSwitch,
        _showOngoingActivityInFullScreen,
      ];

  @override
  bool get stringify => true;
}
