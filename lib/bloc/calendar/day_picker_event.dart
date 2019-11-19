import 'package:meta/meta.dart';

abstract class DayPickerEvent {
  const DayPickerEvent();
}

class NextDay extends DayPickerEvent {}
class PreviousDay extends DayPickerEvent {}
class CurrentDay extends DayPickerEvent {}
class GoTo extends DayPickerEvent {
  final DateTime day;
  GoTo({@required this.day});
}