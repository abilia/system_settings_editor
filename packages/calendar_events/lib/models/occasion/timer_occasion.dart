import 'package:calendar_events/calendar_events.dart';
import 'package:user_files/user_files.dart';

class TimerOccasion extends EventOccasion {
  const TimerOccasion(this.timer, Occasion occasion) : super(occasion);
  final AbiliaTimer timer;
  bool get isOngoing => !timer.paused && occasion.isCurrent;
  TimerOccasion toPast() => TimerOccasion(timer, Occasion.past);
  @override
  EventOccasion toOccasion(DateTime now) => this;
  @override
  String get title => timer.title;
  @override
  String get id => timer.id;
  @override
  DateTime get end => timer.end;
  @override
  DateTime get start => timer.startTime;
  @override
  int get category => Category.right;
  @override
  AbiliaFile get image => timer.image;
  @override
  List<Object?> get props => [timer, occasion];
}
