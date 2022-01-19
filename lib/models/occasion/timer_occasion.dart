import 'package:seagull/models/all.dart';

class TimerOccasion extends TimerDay implements EventOccasion<AbiliaTimer> {
  const TimerOccasion(AbiliaTimer timer, DateTime day, this.occasion)
      : super(timer, day);
  @override
  final Occasion occasion;
}

class TimerDay extends EventDay<AbiliaTimer> {
  const TimerDay(AbiliaTimer timer, DateTime day) : super(timer, day);

  @override
  TimerOccasion toOccasion(DateTime now) => TimerOccasion(
      event,
      day,
      end.isBefore(now)
          ? Occasion.past
          : start.isAfter(now)
              ? Occasion.future
              : Occasion.current);
}
