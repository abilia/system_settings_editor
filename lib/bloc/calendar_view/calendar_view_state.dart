import 'package:equatable/equatable.dart';

class CalendarViewState extends Equatable {
  final CalendarViewType currentView;
  final bool expandRightCategory, expandLeftCategory;
  const CalendarViewState(
    this.currentView, {
    this.expandRightCategory = false,
    this.expandLeftCategory = false,
  });

  @override
  List<Object> get props =>
      [currentView, expandLeftCategory, expandRightCategory];

  CalendarViewState copyWith({
    CalendarViewType currentView,
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

enum CalendarViewType { TIMEPILLAR, LIST }
