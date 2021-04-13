part of 'alarm_settings_cubit.dart';

class AlarmSettingsState extends Equatable {
  final Sound nonCheckableSound, checkableSound, reminderSound;
  final bool vibrateAtReminder;
  final int alarmDuration;

  AlarmSettingsState._({
    this.nonCheckableSound,
    this.checkableSound,
    this.reminderSound,
    this.vibrateAtReminder,
    this.alarmDuration,
  });

  factory AlarmSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AlarmSettingsState._(
        nonCheckableSound: state.nonCheckableAlarm,
        checkableSound: state.checkableAlarm,
        reminderSound: state.reminderAlarm,
        vibrateAtReminder: state.vibrateAtReminder,
        alarmDuration: state.alarmDuration,
      );

  AlarmSettingsState copyWith({
    Sound nonCheckableSound,
    Sound checkableSound,
    Sound reminderSound,
    bool vibrateAtReminder,
    int alarmDuration,
  }) =>
      AlarmSettingsState._(
        nonCheckableSound: nonCheckableSound ?? this.nonCheckableSound,
        checkableSound: checkableSound ?? this.checkableSound,
        reminderSound: reminderSound ?? this.reminderSound,
        vibrateAtReminder: vibrateAtReminder ?? this.vibrateAtReminder,
        alarmDuration: alarmDuration ?? this.alarmDuration,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: nonCheckableSound.name(),
          identifier: MemoplannerSettings.nonCheckableActivityAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: checkableSound.name(),
          identifier: MemoplannerSettings.checkableActivityAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: reminderSound,
          identifier: MemoplannerSettings.reminderAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: vibrateAtReminder,
          identifier: MemoplannerSettings.vibrateAtReminderKey,
        ),
        MemoplannerSettingData.fromData(
          data: alarmDuration,
          identifier: MemoplannerSettings.alarmDurationKey,
        ),
      ];

  @override
  List<Object> get props => [
        nonCheckableSound,
        checkableSound,
        reminderSound,
        vibrateAtReminder,
        alarmDuration,
      ];
}
