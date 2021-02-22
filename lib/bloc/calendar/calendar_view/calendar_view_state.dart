part of 'calendar_view_bloc.dart';

class CalendarViewState extends Equatable {
  final DayCalendarType currentDayCalendarType;
  final bool expandRightCategory, expandLeftCategory;

  const CalendarViewState(
    this.currentDayCalendarType, {
    this.expandRightCategory = true,
    this.expandLeftCategory = true,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : currentDayCalendarType =
            settingsDb?.preferedCalendar ?? DayCalendarType.LIST,
        expandLeftCategory = settingsDb?.leftCategoryExpanded ?? true,
        expandRightCategory = settingsDb?.rightCategoryExpanded ?? true;
  @override
  List<Object> get props => [
        currentDayCalendarType,
        expandLeftCategory,
        expandRightCategory,
      ];

  CalendarViewState copyWith({
    DayCalendarType dayCalendarType,
    bool expandLeftCategory,
    bool expandRightCategory,
  }) =>
      CalendarViewState(
        dayCalendarType ?? currentDayCalendarType,
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
      );
  @override
  String toString() =>
      'CalendarViewState { $currentDayCalendarType,${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', rigth expanded' : ''} }';
}
