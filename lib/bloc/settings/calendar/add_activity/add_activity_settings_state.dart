part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showSilentAlarm,
      showNoAlarm;

  AddActivitySettingsState._({
    @required this.allowPassedStartTime,
    @required this.addRecurringActivity,
    @required this.showEndTime,
    @required this.showAlarm,
    @required this.showSilentAlarm,
    @required this.showNoAlarm,
  });

  factory AddActivitySettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AddActivitySettingsState._(
        allowPassedStartTime: state.activityTimeBeforeCurrent,
        addRecurringActivity: state.activityRecurringEditable,
        showEndTime: state.activityEndTimeEditable,
        showAlarm: state.activityDisplayAlarmOption,
        showSilentAlarm: state.activityDisplaySilentAlarmOption,
        showNoAlarm: state.activityDisplayNoAlarmOption,
      );

  AddActivitySettingsState copyWith({
    bool allowPassedStartTime,
    bool addRecurringActivity,
    bool showEndTime,
    bool showAlarm,
    bool showSilentAlarm,
    bool showNoAlarm,
  }) =>
      AddActivitySettingsState._(
        allowPassedStartTime: allowPassedStartTime ?? this.allowPassedStartTime,
        addRecurringActivity: addRecurringActivity ?? this.addRecurringActivity,
        showEndTime: showEndTime ?? this.showEndTime,
        showAlarm: showAlarm ?? this.showAlarm,
        showSilentAlarm: showSilentAlarm ?? this.showSilentAlarm,
        showNoAlarm: showNoAlarm ?? this.showNoAlarm,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: allowPassedStartTime,
          identifier: MemoplannerSettings.activityTimeBeforeCurrentKey,
        ),
        MemoplannerSettingData.fromData(
          data: addRecurringActivity,
          identifier: MemoplannerSettings.activityRecurringEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: showEndTime,
          identifier: MemoplannerSettings.activityEndTimeEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: showAlarm,
          identifier: MemoplannerSettings.activityDisplayAlarmOptionKey,
        ),
        MemoplannerSettingData.fromData(
          data: showSilentAlarm,
          identifier: MemoplannerSettings.activityDisplaySilentAlarmOptionKey,
        ),
        MemoplannerSettingData.fromData(
          data: showNoAlarm,
          identifier: MemoplannerSettings.activityDisplayNoAlarmOptionKey,
        ),
      ];

  @override
  List<Object> get props => [
        allowPassedStartTime,
        addRecurringActivity,
        showEndTime,
        showAlarm,
        showSilentAlarm,
        showNoAlarm
      ];
}
