import 'package:seagull/models/all.dart';

class TimerOccasion extends EventOccasion {
  const TimerOccasion(this.timer, Occasion occasion) : super(occasion);
  final AbiliaTimer timer;
  bool get isOngoing => !timer.paused && occasion == Occasion.current;
  TimerOccasion toPast() => TimerOccasion(timer, Occasion.past);
  @override
  EventOccasion toOccasion(DateTime now) => this;
  @override
  DateTime get end => timer.endTime;
  @override
  DateTime get start => timer.startTime;
  @override
  int get category => Category.right;
  @override
  AbiliaFile get image => timer.imageFile;
  @override
  List<Object?> get props => [timer, occasion];
  @override
  int compareTo(other) => compare(other);
}
