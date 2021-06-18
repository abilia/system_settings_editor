// @dart=2.9

part of 'month_calendar_settings_cubit.dart';

class MonthCalendarSettingsState extends Equatable {
  final bool browseButtons, year, clock;

  final WeekColor color;

  MonthCalendarSettingsState._({
    @required this.browseButtons,
    @required this.year,
    @required this.clock,
    @required this.color,
  });

  factory MonthCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      MonthCalendarSettingsState._(
        browseButtons: state.monthCaptionShowBrowseButtons,
        year: state.monthCaptionShowYear,
        clock: state.monthCaptionShowClock,
        color: state.monthWeekColor,
      );

  MonthCalendarSettingsState copyWith({
    bool browseButtons,
    bool year,
    bool clock,
    WeekColor color,
  }) =>
      MonthCalendarSettingsState._(
        browseButtons: browseButtons ?? this.browseButtons,
        year: year ?? this.year,
        clock: clock ?? this.clock,
        color: color ?? this.color,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: browseButtons,
          identifier: MemoplannerSettings.monthCaptionShowMonthButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: year,
          identifier: MemoplannerSettings.monthCaptionShowYearKey,
        ),
        MemoplannerSettingData.fromData(
          data: clock,
          identifier: MemoplannerSettings.monthCaptionShowClockKey,
        ),
        MemoplannerSettingData.fromData(
          data: color.index,
          identifier: MemoplannerSettings.calendarMonthViewShowColorsKey,
        ),
      ];

  @override
  List<Object> get props => [
        browseButtons,
        year,
        clock,
        color,
      ];
}
