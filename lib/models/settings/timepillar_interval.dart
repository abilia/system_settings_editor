import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class TimepillarInterval extends Equatable {
  final DateTime startTime, endTime;
  final IntervalPart intervalPart;

  TimepillarInterval({
    required DateTime start,
    required DateTime end,
    this.intervalPart = IntervalPart.day,
  })  : startTime = start.copyWith(minute: 0),
        endTime = end.copyWith(minute: 0);

  factory TimepillarInterval.dayAndNight(DateTime day) => TimepillarInterval(
        start: day,
        end: day.addDays(1),
        intervalPart: IntervalPart.dayAndNight,
      );

  late final int lengthInHours =
      (endTime.difference(startTime).inMinutes / 60).ceil();

  Occasion occasion(DateTime now) => now.isBefore(startTime)
      ? Occasion.future
      : now.isAfter(endTime)
          ? Occasion.past
          : Occasion.current;

  @override
  List<Object> get props => [startTime, endTime, intervalPart];

  @override
  bool get stringify => true;
}
