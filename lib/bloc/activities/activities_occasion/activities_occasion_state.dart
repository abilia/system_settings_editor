import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/utils.dart';

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
  final DateTime day;

  ActivitiesOccasionLoaded({
    @required this.activities,
    @required this.fullDayActivities,
    @required this.day,
  }) : super();

  @override
  List<Object> get props => [activities, fullDayActivities, day];
  @override
  String toString() =>
      'ActivitiesOccasionLoaded { ActivityOccasion: $activities, fullDay ActivityOccasion: $fullDayActivities }';
}

enum Occasion { past, current, future }

class ActivityOccasion extends Equatable {
  ActivityOccasion._(this.activity, this.occasion);
  ActivityOccasion(
    this.activity, {
    @required DateTime now,
    @required DateTime day,
  }) : occasion = activity.endClock(day).isBefore(now)
            ? Occasion.past
            : activity.startClock(day).isAfter(now)
                ? Occasion.future
                : Occasion.current;

  @visibleForTesting
  factory ActivityOccasion.forTest(activity, occasion) =>
      ActivityOccasion._(activity, occasion);

  factory ActivityOccasion.fullDay(
    Activity activity, {
    @required DateTime now,
    @required DateTime day,
  }) =>
      ActivityOccasion._(
          activity,
          isDayBefore(activity.startClock(day), now)
              ? Occasion.past
              : Occasion.future);

  final Activity activity;
  final Occasion occasion;

  @override
  List<Object> get props => [activity, occasion];

  @override
  String toString() =>
      '{ $occasion,  Activity: ( ${activity.title} ${activity.start}-${activity.end} ) }';
}
