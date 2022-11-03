import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class TimepillarInterval extends Equatable {
  final DateTime start, end;
  final IntervalPart intervalPart;

  TimepillarInterval({
    required DateTime start,
    required DateTime end,
    this.intervalPart = IntervalPart.day,
  })  : start = start.copyWith(minute: 0),
        end = end.copyWith(minute: 0);

  factory TimepillarInterval.dayAndNight(DateTime day) => TimepillarInterval(
        start: day,
        end: day.addDays(1),
        intervalPart: IntervalPart.dayAndNight,
      );

  late final int lengthInHours = (end.difference(start).inMinutes / 60).ceil();
  late final bool spansMidnight = end.isDayAfter(start);
  late final daySpan = spansMidnight ? 2 : 1;

  Occasion occasion(DateTime now) => now.isBefore(start)
      ? Occasion.future
      : now.isAfter(end)
          ? Occasion.past
          : Occasion.current;

  @override
  List<Object> get props => [start, end, intervalPart];

  @override
  bool get stringify => true;
}
