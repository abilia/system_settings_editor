part of 'general_calendar_settings_cubit.dart';

class GeneralCalendarSettingsState extends Equatable {
  final ClockType clockType;
  final bool timeline, hourLines, columnOfDots, use12h;

  GeneralCalendarSettingsState._(
    this.clockType,
    this.use12h,
    this.timeline,
    this.hourLines,
    this.columnOfDots,
  );

  factory GeneralCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      GeneralCalendarSettingsState._(
        state.clockType,
        state.timepillar12HourFormat,
        state.displayTimeline,
        state.displayHourLines,
        state.columnOfDots,
      );

  GeneralCalendarSettingsState copyWith({
    ClockType clockType,
    bool use12h,
    bool timeline,
    bool hourLines,
    bool columnOfDots,
  }) =>
      GeneralCalendarSettingsState._(
        clockType ?? this.clockType,
        use12h ?? this.use12h,
        timeline ?? this.timeline,
        hourLines ?? this.hourLines,
        columnOfDots ?? this.columnOfDots,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: clockType.index,
          identifier: MemoplannerSettings.settingClockTypeKey,
        ),
        MemoplannerSettingData.fromData(
          data: use12h,
          identifier: MemoplannerSettings.setting12hTimeFormatTimelineKey,
        ),
        MemoplannerSettingData.fromData(
          data: timeline,
          identifier: MemoplannerSettings.settingDisplayTimelineKey,
        ),
        MemoplannerSettingData.fromData(
          data: hourLines,
          identifier: MemoplannerSettings.settingDisplayHourLinesKey,
        ),
        MemoplannerSettingData.fromData(
          data: columnOfDots,
          identifier: MemoplannerSettings.settingTimePillarTimelineKey,
        ),
      ];

  @override
  List<Object> get props => [
        clockType,
        use12h,
        timeline,
        hourLines,
        columnOfDots,
      ];
}
