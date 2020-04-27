import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/utils/all.dart';

@immutable
abstract class ActivitiesOccasionState extends Equatable {
  const ActivitiesOccasionState();
  @override
  List<Object> get props => [];
}

class ActivitiesOccasionLoading extends ActivitiesOccasionState {
  ActivitiesOccasionLoading() : super();
  @override
  String toString() => 'ActivitiesOccasionLoading';
}

class ActivitiesOccasionLoaded extends ActivitiesOccasionState {
  final List<ActivityOccasion> activities;
  final List<ActivityOccasion> fullDayActivities;
  final int indexOfCurrentActivity;
  final Occasion occasion;
  final DateTime day;
  bool get isToday => occasion == Occasion.current;

  ActivitiesOccasionLoaded({
    @required this.activities,
    @required this.fullDayActivities,
    @required this.indexOfCurrentActivity,
    @required this.day,
    @required this.occasion,
  }) : super();

  @override
  List<Object> get props =>
      [activities, fullDayActivities, day, indexOfCurrentActivity, isToday];
  @override
  String toString() =>
      'ActivitiesOccasionLoaded { ActivityOccasion: $activities, fullDay ActivityOccasion: $fullDayActivities, day; $day, indexOfCurrentActivity; $indexOfCurrentActivity, [${isToday ? '' : ' not '} today ] }';
}

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
