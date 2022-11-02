part of 'calendar_view_cubit.dart';

class CalendarViewState extends Equatable {
  final bool expandRightCategory, expandLeftCategory;

  const CalendarViewState({
    required this.expandRightCategory,
    required this.expandLeftCategory,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : expandLeftCategory = settingsDb.leftCategoryExpanded,
        expandRightCategory = settingsDb.rightCategoryExpanded;

  @override
  List<Object> get props => [expandLeftCategory, expandRightCategory];

  CalendarViewState copyWith({
    bool? expandLeftCategory,
    bool? expandRightCategory,
    StartView? calendarTab,
  }) =>
      CalendarViewState(
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
      );

  @override
  String toString() =>
      'CalendarViewState { ${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', right expanded' : ''} }';
}
