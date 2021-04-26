part of 'general_calendar_settings_cubit.dart';

class GeneralCalendarSettingsState extends Equatable {
  final ClockType clockType;
  final TimepillarSettingState timepillar;
  final DayParts dayParts;
  final DayColor dayColor;
  final CategoriesSettingState categories;

  GeneralCalendarSettingsState._(
    this.clockType,
    this.timepillar,
    this.dayParts,
    this.dayColor,
    this.categories,
  );

  factory GeneralCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      GeneralCalendarSettingsState._(
        state.clockType,
        TimepillarSettingState.fromMemoplannerSettings(state),
        state.dayParts,
        state.calendarDayColor,
        CategoriesSettingState.fromMemoplannerSettings(state),
      );

  GeneralCalendarSettingsState copyWith({
    ClockType clockType,
    TimepillarSettingState timepillar,
    DayParts dayParts,
    DayColor dayColor,
    CategoriesSettingState categories,
  }) =>
      GeneralCalendarSettingsState._(
        clockType ?? this.clockType,
        timepillar ?? this.timepillar,
        dayParts ?? this.dayParts,
        dayColor ?? this.dayColor,
        categories ?? this.categories,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: clockType.index,
          identifier: MemoplannerSettings.settingClockTypeKey,
        ),
        ...timepillar.memoplannerSettingData,
        ...dayParts.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: dayColor.index,
          identifier: MemoplannerSettings.calendarDayColorKey,
        ),
        ...categories.memoplannerSettingData,
      ];

  @override
  List<Object> get props => [
        clockType,
        timepillar,
        dayParts,
        dayColor,
        categories,
      ];
}

class TimepillarSettingState extends Equatable {
  final bool timeline, hourLines, columnOfDots, use12h;

  TimepillarSettingState._(
    this.use12h,
    this.timeline,
    this.hourLines,
    this.columnOfDots,
  );

  factory TimepillarSettingState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      TimepillarSettingState._(
        state.timepillar12HourFormat,
        state.displayTimeline,
        state.displayHourLines,
        state.columnOfDots,
      );

  TimepillarSettingState copyWith({
    bool use12h,
    bool timeline,
    bool hourLines,
    bool columnOfDots,
  }) =>
      TimepillarSettingState._(
        use12h ?? this.use12h,
        timeline ?? this.timeline,
        hourLines ?? this.hourLines,
        columnOfDots ?? this.columnOfDots,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
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
        use12h,
        timeline,
        hourLines,
        columnOfDots,
      ];
}

class CategoriesSettingState extends Equatable {
  final bool showCategories, showColors;
  final String rigthCategoryName, leftCategoryName;

  CategoriesSettingState._(
    this.showCategories,
    this.showColors,
    this.rigthCategoryName,
    this.leftCategoryName,
  )   : assert(showCategories != null),
        assert(showColors != null),
        assert(leftCategoryName != null),
        assert(rigthCategoryName != null);

  factory CategoriesSettingState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      CategoriesSettingState._(
        state.showCategories,
        state.showColor,
        state.rightCategoryName ?? '',
        state.leftCategoryName ?? '',
      );

  CategoriesSettingState copyWith({
    bool showCategories,
    bool showColors,
    String rigthCategoryName,
    String leftCategoryName,
  }) =>
      CategoriesSettingState._(
        showCategories ?? this.showCategories,
        showColors ?? this.showColors,
        rigthCategoryName ?? this.rigthCategoryName,
        leftCategoryName ?? this.leftCategoryName,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showCategories,
          identifier: MemoplannerSettings.calendarActivityTypeShowTypesKey,
        ),
        MemoplannerSettingData.fromData(
          data: showColors,
          identifier: MemoplannerSettings.calendarActivityTypeShowColorKey,
        ),
        MemoplannerSettingData.fromData(
          data: rigthCategoryName,
          identifier: MemoplannerSettings.calendarActivityTypeRightKey,
        ),
        MemoplannerSettingData.fromData(
          data: leftCategoryName,
          identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
        ),
      ];

  @override
  List<Object> get props => [
        showCategories,
        showColors,
        rigthCategoryName,
        leftCategoryName,
      ];
}

extension DayPartLimit on DayParts {
  bool atMax(DayPart part) => fromDayPart(part) >= DayParts.limits[part].max;
  bool atMin(DayPart part) => fromDayPart(part) <= DayParts.limits[part].min;
}

extension _MemoplannerSettingData on DayParts {
  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: morningStart,
          identifier: MemoplannerSettings.morningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: forenoonStart,
          identifier: MemoplannerSettings.forenoonIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: eveningStart,
          identifier: MemoplannerSettings.eveningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: nightStart,
          identifier: MemoplannerSettings.nightIntervalStartKey,
        ),
      ];
}
