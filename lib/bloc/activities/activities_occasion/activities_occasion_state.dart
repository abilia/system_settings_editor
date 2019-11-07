import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/utils/datetime_utils.dart';

abstract class ActivitiesOccasionState extends Equatable {
  const ActivitiesOccasionState(this.now);
  final DateTime now;
  @override
  List<Object> get props => [];
}

class ActivitiesOccasionLoading extends ActivitiesOccasionState {
  ActivitiesOccasionLoading(DateTime now) : super(now);
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
  List<Object> get props => [activities];
}

enum Occasion { past, current, future }

class ActivityOccasion extends Equatable {
  ActivityOccasion._(this.activity, this.occasion);
  ActivityOccasion(this.activity, {@required DateTime now})
      : occasion = activity.endDate.isBefore(now) &&
                !activity.endDate.isAtSameMomentAs(now)
            ? Occasion.past
            : activity.startDate.isAfter(now) &&
                    !activity.startDate.isAtSameMomentAs(now)
                ? Occasion.future
                : Occasion.current;

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
}
