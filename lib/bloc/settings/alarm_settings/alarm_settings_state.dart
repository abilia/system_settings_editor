part of 'alarm_settings_cubit.dart';

class AlarmSettingsState extends Equatable {
  final Sound nonCheckableSound, checkableSound, reminderSound;
  final bool vibrateAtReminder;
  final AlarmDuration alarmDuration;

  AlarmSettingsState._({
    required this.nonCheckableSound,
    required this.checkableSound,
    required this.reminderSound,
    required this.vibrateAtReminder,
    required this.alarmDuration,
  });

  factory AlarmSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AlarmSettingsState._(
        nonCheckableSound: state.nonCheckableAlarm,
        checkableSound: state.checkableAlarm,
        reminderSound: state.reminderAlarm,
        vibrateAtReminder: state.vibrateAtReminder,
        alarmDuration: state.alarmDuration.toAlarmDuration(),
      );

  AlarmSettingsState copyWith({
    Sound? nonCheckableSound,
    Sound? checkableSound,
    Sound? reminderSound,
    bool? vibrateAtReminder,
    AlarmDuration? alarmDuration,
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
          data: reminderSound.name(),
          identifier: MemoplannerSettings.reminderAlarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: vibrateAtReminder,
          identifier: MemoplannerSettings.vibrateAtReminderKey,
        ),
        MemoplannerSettingData.fromData(
          data: alarmDuration.milliseconds(),
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
