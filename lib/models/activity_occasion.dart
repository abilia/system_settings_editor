import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

enum Occasion { past, current, future }

class ActivityOccasion extends Equatable {
  final DateTime day;
  ActivityOccasion._(this.activity, this.occasion, this.day);
  ActivityOccasion(
    this.activity, {
    @required DateTime now,
    @required this.day,
  }) : occasion = activity.endClock(day).isBefore(now)
            ? Occasion.past
            : activity.startClock(day).isAfter(now)
                ? Occasion.future
                : Occasion.current;

  @visibleForTesting
  factory ActivityOccasion.forTest(
    Activity activity, {
    Occasion occasion = Occasion.current,
    DateTime day,
  }) =>
      ActivityOccasion._(
          activity, occasion, day ?? activity.startTime.onlyDays());

  factory ActivityOccasion.fullDay(
    Activity activity, {
    @required DateTime now,
    @required DateTime day,
  }) =>
      ActivityOccasion._(
          activity,
          activity.startClock(day).isDayBefore(now)
              ? Occasion.past
              : Occasion.future,
          day);

  final Activity activity;
  final Occasion occasion;

  @override
  List<Object> get props => [activity, occasion, day];

  @override
  String toString() =>
      '{ $occasion,  Activity: ( ${activity.title} ${activity.startTime}-${activity.end} ) day: $day }';
}
