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
    ClockType? clockType,
    TimepillarSettingState? timepillar,
    DayParts? dayParts,
    DayColor? dayColor,
    CategoriesSettingState? categories,
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
    bool? use12h,
    bool? timeline,
    bool? hourLines,
    bool? columnOfDots,
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
  final bool show, colors;
  final ImageAndName left, right;

  CategoriesSettingState._(
    this.show,
    this.colors,
    this.left,
    this.right,
  );

  factory CategoriesSettingState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      CategoriesSettingState._(
        state.showCategories,
        state.showCategoryColor,
        ImageAndName(
          state.leftCategoryName,
          SelectedImage.from(id: state.leftCategoryImage),
        ),
        ImageAndName(
          state.rightCategoryName,
          SelectedImage.from(id: state.rightCategoryImage),
        ),
      );

  CategoriesSettingState copyWith({
    bool? show,
    bool? colors,
    ImageAndName? left,
    ImageAndName? right,
  }) =>
      CategoriesSettingState._(
        show ?? this.show,
        colors ?? this.colors,
        left ?? this.left,
        right ?? this.right,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: show,
          identifier: MemoplannerSettings.calendarActivityTypeShowTypesKey,
        ),
        MemoplannerSettingData.fromData(
          data: colors,
          identifier: MemoplannerSettings.calendarActivityTypeShowColorKey,
        ),
        MemoplannerSettingData.fromData(
          data: left.name,
          identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
        ),
        MemoplannerSettingData.fromData(
          data: right.name,
          identifier: MemoplannerSettings.calendarActivityTypeRightKey,
        ),
        MemoplannerSettingData.fromData(
          data: left.image.id,
          identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
        ),
        MemoplannerSettingData.fromData(
          data: right.image.id,
          identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
        ),
      ];

  @override
  List<Object> get props => [
        show,
        colors,
        left,
        right,
      ];
}

extension DayPartLimit on DayParts {
  bool atMax(DayPart part) => fromDayPart(part) >= DayParts.limits[part]!.max;
  bool atMin(DayPart part) => fromDayPart(part) <= DayParts.limits[part]!.min;
}

extension _MemoplannerSettingData on DayParts {
  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: morningStart,
          identifier: MemoplannerSettings.morningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: dayStart,
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
