import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/utils/datetime_utils.dart';

abstract class ActivitiesOccasionState extends Equatable {
  const ActivitiesOccasionState(this.now);
  final DateTime now;
  @override
  List<Object> get props => [now];
}

class ActivitiesOccasionLoading extends ActivitiesOccasionState {
  ActivitiesOccasionLoading(DateTime now) : super(now);
  @override
  String toString() => 'ActivitiesOccasionLoading { now: $now }';
}

class ActivitiesOccasionLoaded extends ActivitiesOccasionState {
  ActivitiesOccasionLoaded(
      {@required this.activities,
      @required this.fullDayActivities,
      @required DateTime now})
      : super(now);
  final List<ActivityOccasion> activities;
  final List<ActivityOccasion> fullDayActivities;

  @override
  List<Object> get props => [activities, fullDayActivities, now];
  @override
  String toString() =>
      'ActivitiesOccasionLoaded { ActivityOccasion: $activities, fullDay ActivityOccasion: $fullDayActivities  now: $now }';
}

enum Occasion { past, current, future }

class ActivityOccasion extends Equatable {
  ActivityOccasion._(this.activity, this.occasion);
  ActivityOccasion(this.activity, {@required DateTime now})
      : occasion = activity.endDate.isBefore(now)
            ? Occasion.past
            : activity.startDate.isAfter(now)
                ? Occasion.future
                : Occasion.current;

  @visibleForTesting
  factory ActivityOccasion.forTest(activity, occasion) =>
      ActivityOccasion._(activity, occasion);

  factory ActivityOccasion.fullDay(Activity activity,
          {@required DateTime now}) =>
      ActivityOccasion._(
          activity,
          isDayBefore(activity.startDate, now)
              ? Occasion.past
              : Occasion.future);

  final Activity activity;
  final Occasion occasion;

  @override
  List<Object> get props => [activity, occasion];

  @override
  String toString() =>
      '{ $occasion,  Activity: ( ${activity.title} ${activity.startDate}-${activity.endDate} ) }';
}
