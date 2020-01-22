import 'package:equatable/equatable.dart';

class CalendarViewState extends Equatable {
  final CalendarViewType currentView;
  const CalendarViewState(this.currentView);

  @override
  List<Object> get props => [currentView];
}

enum CalendarViewType { TIMEPILLAR, LIST }
