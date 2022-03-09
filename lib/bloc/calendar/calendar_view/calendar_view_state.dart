part of 'calendar_view_cubit.dart';

class CalendarViewState extends Equatable {
  final bool expandRightCategory, expandLeftCategory;
  final StartView calendarTab;

  const CalendarViewState({
    required this.expandRightCategory,
    required this.expandLeftCategory,
    this.calendarTab = StartView.dayCalendar,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : expandLeftCategory = settingsDb.leftCategoryExpanded,
        expandRightCategory = settingsDb.rightCategoryExpanded,
        calendarTab = StartView.dayCalendar;

  @override
  List<Object> get props =>
      [expandLeftCategory, expandRightCategory, calendarTab];

  CalendarViewState copyWith({
    bool? expandLeftCategory,
    bool? expandRightCategory,
    StartView? calendarTab,
  }) =>
      CalendarViewState(
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
        calendarTab: calendarTab ?? this.calendarTab,
      );

  @override
  String toString() =>
      'CalendarViewState { ${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', right expanded' : ''}, calendarIndex : ${calendarTab.toString()} }';
}
