part of 'calendar_view_bloc.dart';

class CalendarViewState extends Equatable {
  final CalendarType currentView;
  final bool expandRightCategory, expandLeftCategory;
  const CalendarViewState(
    this.currentView, {
    this.expandRightCategory = true,
    this.expandLeftCategory = true,
  });

  CalendarViewState.fromSettings(SettingsDb settingsDb)
      : currentView = settingsDb?.preferedCalender ?? CalendarType.LIST,
        expandLeftCategory = settingsDb?.leftCategoryExpanded ?? true,
        expandRightCategory = settingsDb?.rightCategoryExpanded ?? true;

  @override
  List<Object> get props =>
      [currentView, expandLeftCategory, expandRightCategory];

  CalendarViewState copyWith({
    CalendarType currentView,
    bool expandLeftCategory,
    bool expandRightCategory,
  }) =>
      CalendarViewState(
        currentView ?? this.currentView,
        expandLeftCategory: expandLeftCategory ?? this.expandLeftCategory,
        expandRightCategory: expandRightCategory ?? this.expandRightCategory,
      );
  @override
  String toString() =>
      'CalendarViewState { $currentView,${expandLeftCategory ? ', left expanded' : ''}${expandRightCategory ? ', rigth expanded' : ''} }';
}
