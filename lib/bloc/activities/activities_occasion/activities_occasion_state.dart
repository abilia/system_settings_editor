import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/activity.dart';

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
  ActivitiesOccasionLoaded(this.activityStates, DateTime now) : super(now);
  final List<ActivityOccasion> activityStates;

  @override
  List<Object> get props => [activityStates];
}

enum Occasion { past, current, future }

class ActivityOccasion extends Equatable {
  ActivityOccasion(this.activity, {@required DateTime now})
      : occasion = activity.endDate.isBefore(now) &&
                !activity.endDate.isAtSameMomentAs(now)
            ? Occasion.past
            : activity.startDate.isAfter(now) &&
                    !activity.startDate.isAtSameMomentAs(now)
                ? Occasion.future
                : Occasion.current;

  final Activity activity;
  final Occasion occasion;

  @override
  List<Object> get props => [activity, occasion];
}
