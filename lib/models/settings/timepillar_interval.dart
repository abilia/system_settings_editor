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

  int get lengthInHours =>
      (endTime.difference(startTime).inMinutes / 60).ceil();

  List<ActivityOccasion> getForInterval(List<ActivityOccasion> activities) {
    return activities
        .where((a) =>
            a.start.inRangeWithInclusiveStart(
                startDate: startTime, endDate: endTime) ||
            (a.start.isBefore(startTime) && a.end.isAfter(startTime)))
        .toList();
  }

  @override
  List<Object> get props => [startTime, endTime];
  @override
  bool get stringify => true;
}
