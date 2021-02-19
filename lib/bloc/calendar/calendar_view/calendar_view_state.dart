part of 'calendar_view_bloc.dart';

class CalendarViewState extends Equatable {
  final DayCalendarType currentDayCalendarType;
  final bool expandRightCategory, expandLeftCategory;
  final CalendarPeriod currentCalendarPeriod;

  const CalendarViewState(
    this.currentDayCalendarType, {
    this.expandRightCategory = true,
    this.expandLeftCategory = true,
    this.currentCalendarPeriod = CalendarPeriod.DAY,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : currentDayCalendarType =
            settingsDb?.preferedCalendar ?? DayCalendarType.LIST,
        expandLeftCategory = settingsDb?.leftCategoryExpanded ?? true,
        expandRightCategory = settingsDb?.rightCategoryExpanded ?? true,
        currentCalendarPeriod = CalendarPeriod.DAY;

  @override
  List<Object> get props => [
        currentDayCalendarType,
        expandLeftCategory,
        expandRightCategory,
        currentCalendarPeriod,
      ];

  CalendarViewState copyWith({
    DayCalendarType dayCalendarType,
    bool expandLeftCategory,
    bool expandRightCategory,
    CalendarPeriod calendarPeriod,
  }) =>
      CalendarViewState(
        dayCalendarType ?? currentDayCalendarType,
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
        currentCalendarPeriod: calendarPeriod ?? currentCalendarPeriod,
      );
  @override
  String toString() =>
      'CalendarViewState { $currentDayCalendarType,${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', rigth expanded' : ''} }';
}
