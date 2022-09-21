part of 'day_calendar_settings_cubit.dart';

class DayCalendarSettingsState extends Equatable {
  final bool showBrowseButtons, showWeekday, showDayPeriod, showDate, showClock;

// Eye button settings
  final bool showTypeOfDisplay,
      showTimepillarLength,
      showTimelineZoom,
      showDurationSelection;

  final bool dotsInTimePillar;
  final TimepillarZoom timepillarZoom;
  final TimepillarIntervalType dayInterval;
  final DayCalendarType calendarType;

  const DayCalendarSettingsState._({
    required this.showBrowseButtons,
    required this.showWeekday,
    required this.showDayPeriod,
    required this.showDate,
    required this.showClock,
    required this.dotsInTimePillar,
    required this.timepillarZoom,
    required this.dayInterval,
    required this.calendarType,
    required this.showTypeOfDisplay,
    required this.showTimepillarLength,
    required this.showTimelineZoom,
    required this.showDurationSelection,
  });

  factory DayCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      DayCalendarSettingsState._(
        showBrowseButtons: state.settings.appBar.dayCaptionShowDayButtons,
        showWeekday: state.settings.appBar.activityDisplayWeekDay,
        showDayPeriod: state.settings.appBar.activityDisplayDayPeriod,
        showDate: state.settings.appBar.activityDisplayDate,
        showClock: state.settings.appBar.activityDisplayClock,
        calendarType: state.dayCalendarType,
        dayInterval: state.timepillarIntervalType,
        dotsInTimePillar: state.dotsInTimepillar,
        timepillarZoom: state.timepillarZoom,
        showTypeOfDisplay: state.settingViewOptionsTimeView,
        showTimepillarLength: state.settingViewOptionsTimeInterval,
        showTimelineZoom: state.settingViewOptionsZoom,
        showDurationSelection: state.settingViewOptionsDurationDots,
      );

  DayCalendarSettingsState copyWith({
    bool? showBrowseButtons,
    bool? showWeekday,
    bool? showDayPeriod,
    bool? showDate,
    bool? showClock,
    DayCalendarType? calendarType,
    TimepillarIntervalType? dayInterval,
    bool? dotsInTimePillar,
    TimepillarZoom? timepillarZoom,
    bool? showTypeOfDisplay,
    bool? showTimepillarLength,
    bool? showTimelineZoom,
    bool? showDurationSelection,
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
        showTypeOfDisplay: showTypeOfDisplay ?? this.showTypeOfDisplay,
        showTimepillarLength: showTimepillarLength ?? this.showTimepillarLength,
        showTimelineZoom: showTimelineZoom ?? this.showTimelineZoom,
        showDurationSelection:
            showDurationSelection ?? this.showDurationSelection,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: AppBarSettings.dayCaptionShowDayButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showWeekday,
          identifier: AppBarSettings.activityDisplayWeekDayKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDayPeriod,
          identifier: AppBarSettings.activityDisplayDayPeriodKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDate,
          identifier: AppBarSettings.activityDisplayDateKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: AppBarSettings.activityDisplayClockKey,
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
        MemoplannerSettingData.fromData(
          data: showTypeOfDisplay,
          identifier: MemoplannerSettings.settingViewOptionsTimeViewKey,
        ),
        MemoplannerSettingData.fromData(
          data: showTimepillarLength,
          identifier: MemoplannerSettings.settingViewOptionsTimeIntervalKey,
        ),
        MemoplannerSettingData.fromData(
          data: showTimelineZoom,
          identifier: MemoplannerSettings.settingViewOptionsZoomKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDurationSelection,
          identifier: MemoplannerSettings.settingViewOptionsDurationDotsKey,
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
        showTypeOfDisplay,
        showTimepillarLength,
        showTimelineZoom,
        showDurationSelection,
      ];
}
