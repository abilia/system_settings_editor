part of 'alarm_settings_cubit.dart';

extension AlarmSettingsState on AlarmSettings {
  Sound get nonCheckableSound => nonCheckableActivity.toSound();
  Sound get checkableSound => checkableActivity.toSound();
  Sound get reminderSound => reminder.toSound();
  AlarmDuration get alarmDuration => durationMs.toAlarmDuration();

  AlarmSettings copyWith({
    Sound? nonCheckableSound,
    Sound? checkableSound,
    Sound? reminderSound,
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
        showAlarmOnOffSwitch: showAlarmOnOffSwitch ?? this.showAlarmOnOffSwitch,
        showOngoingActivityInFullScreen: showOngoingActivityInFullScreen ??
            this.showOngoingActivityInFullScreen,
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
            data: showOngoingActivityInFullScreen,
            identifier: AlarmSettings.showOngoingActivityInFullScreenKey)
      ];
}
