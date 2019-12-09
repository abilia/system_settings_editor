import 'package:meta/meta.dart';

@immutable
abstract class DayPickerEvent {
  const DayPickerEvent();
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
  @override
  String toString() => 'CurrentDay';
}

class GoTo extends DayPickerEvent {
  final DateTime day;
  GoTo({@required this.day});
  @override
  String toString() => 'GoTo $day';
}
