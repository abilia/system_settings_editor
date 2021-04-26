part of 'calendar_view_bloc.dart';

class CalendarViewState extends Equatable {
  final bool expandRightCategory, expandLeftCategory;

  const CalendarViewState({
    this.expandRightCategory = true,
    this.expandLeftCategory = true,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : expandLeftCategory = settingsDb?.leftCategoryExpanded ?? true,
        expandRightCategory = settingsDb?.rightCategoryExpanded ?? true;
  @override
  List<Object> get props => [
        expandLeftCategory,
        expandRightCategory,
      ];

  CalendarViewState copyWith({
    DayCalendarType dayCalendarType,
    bool expandLeftCategory,
    bool expandRightCategory,
  }) =>
      CalendarViewState(
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
      );
  @override
  String toString() =>
      'CalendarViewState { ${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', rigth expanded' : ''} }';
}
