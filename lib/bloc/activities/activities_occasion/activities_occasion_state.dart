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
  final DateTime day;
  final bool isToday;

  ActivitiesOccasionLoaded({
    @required this.activities,
    @required this.fullDayActivities,
    @required this.indexOfCurrentActivity,
    @required this.day,
    @required this.isToday,
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
  factory ActivityOccasion.forTest(activity, occasion) =>
      ActivityOccasion._(activity, occasion, null);

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
      '{ $occasion,  Activity: ( ${activity.title} ${activity.start}-${activity.end} ) }';
}
