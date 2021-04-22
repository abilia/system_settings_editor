part of 'day_calendar_settings_cubit.dart';

class DayCalendarSettingsState extends Equatable {
  final bool showBrowseButtons, showWeekday, showDayPeriod, showDate, showClock;

  final bool dotsInTimePillar;
  final TimepillarZoom timepillarZoom;
  final TimepillarIntervalType dayInterval;
  final DayCalendarType calendarType;

  DayCalendarSettingsState._({
    @required this.showBrowseButtons,
    @required this.showWeekday,
    @required this.showDayPeriod,
    @required this.showDate,
    @required this.showClock,
    @required this.dotsInTimePillar,
    @required this.timepillarZoom,
    @required this.dayInterval,
    @required this.calendarType,
  });

  factory DayCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      DayCalendarSettingsState._(
        showBrowseButtons: state.dayCaptionShowDayButtons,
        showWeekday: state.activityDisplayWeekDay,
        showDayPeriod: state.activityDisplayDayPeriod,
        showDate: state.activityDisplayDate,
        showClock: state.activityDisplayClock,
        calendarType: state.dayCalendarType,
        dayInterval: state.timepillarIntervalType,
        dotsInTimePillar: state.dotsInTimepillar,
        timepillarZoom: state.timepillarZoom,
      );

  DayCalendarSettingsState copyWith({
    bool showBrowseButtons,
    bool showWeekday,
    bool showDayPeriod,
    bool showDate,
    bool showClock,
    DayCalendarType calendarType,
    TimepillarIntervalType dayInterval,
    bool dotsInTimePillar,
    TimepillarZoom timepillarZoom,
  }) =>
      DayCalendarSettingsState._(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekday: showWeekday ?? this.showWeekday,
        showDayPeriod: showDayPeriod ?? this.showDayPeriod,
        showDate: showDate ?? this.showDate,
        showClock: showClock ?? this.showClock,
        calendarType: calendarType ?? this.calendarType,
        dayInterval: dayInterval ?? this.dayInterval,
        dotsInTimePillar: dotsInTimePillar ?? this.dotsInTimePillar,
        timepillarZoom: timepillarZoom ?? this.timepillarZoom,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: MemoplannerSettings.dayCaptionShowDayButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showWeekday,
          identifier: MemoplannerSettings.activityDisplayWeekDayKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDayPeriod,
          identifier: MemoplannerSettings.activityDisplayDayPeriodKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDate,
          identifier: MemoplannerSettings.activityDisplayDateKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: MemoplannerSettings.activityDisplayClockKey,
        ),
        MemoplannerSettingData.fromData(
          data: calendarType.index,
          identifier: MemoplannerSettings.viewOptionsTimeViewKey,
        ),
        MemoplannerSettingData.fromData(
          data: dayInterval.index,
          identifier: MemoplannerSettings.viewOptionsTimeIntervalKey,
        ),
        MemoplannerSettingData.fromData(
          data: dotsInTimePillar,
          identifier: MemoplannerSettings.dotsInTimepillarKey,
        ),
        MemoplannerSettingData.fromData(
          data: timepillarZoom.index,
          identifier: MemoplannerSettings.viewOptionsZoomKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
        showWeekday,
        showDayPeriod,
        showDate,
        showClock,
        calendarType,
        dayInterval,
        dotsInTimePillar,
        timepillarZoom,
      ];
}
