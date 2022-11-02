part of 'day_picker_bloc.dart';

abstract class DayPickerEvent extends Equatable {
  const DayPickerEvent();
  @override
  List<Object> get props => [];
}

class NextDay extends DayPickerEvent {
  @override
  String toString() => 'NextDay';
}

class PreviousDay extends DayPickerEvent {
  @override
  String toString() => 'PreviousDay';
}

class CurrentDay extends DayPickerEvent {
  const CurrentDay();
  @override
  String toString() => 'CurrentDay';
}

class GoTo extends DayPickerEvent {
  final DateTime day;
  const GoTo({required this.day});
  @override
  String toString() => 'GoTo $day';
}

class TimeChanged extends DayPickerEvent {
  final DateTime now;
  const TimeChanged(this.now);
  @override
  List<Object> get props => [now];
}
