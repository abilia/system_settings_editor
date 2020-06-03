import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

enum Occasion { past, current, future }

class ActivityOccasion extends ActivityDay {
  final Occasion occasion;
  ActivityOccasion._(Activity activity, this.occasion, DateTime day)
      : super(activity, day);
  ActivityOccasion(
    ActivityDay activityDay, {
    @required DateTime now,
  })  : occasion = activityDay.end.isBefore(now)
            ? Occasion.past
            : activityDay.start.isAfter(now)
                ? Occasion.future
                : Occasion.current,
        super.copy(activityDay);

  @visibleForTesting
  factory ActivityOccasion.forTest(
    Activity activity, {
    Occasion occasion = Occasion.current,
    DateTime day,
  }) =>
      ActivityOccasion._(
          activity, occasion, day ?? activity.startTime.onlyDays());

  factory ActivityOccasion.fullDay(
    ActivityDay activityDay, {
    @required DateTime now,
  }) =>
      ActivityOccasion._(
          activityDay.activity,
          activityDay.start.isDayBefore(now) ? Occasion.past : Occasion.future,
          activityDay.day);

  @override
  List<Object> get props => [occasion, ...super.props];
}

class ActivityDay extends Equatable {
  final DateTime day;
  final Activity activity;
  DateTime get start => activity.startClock(day);
  DateTime get end => activity.endClock(day);
  bool get isSignedOff =>
      activity.checkable && activity.signedOffDates.contains(day);

  const ActivityDay(this.activity, this.day)
      : assert(activity != null),
        assert(day != null);
  ActivityDay.copy(ActivityDay ad) : this(ad.activity, ad.day);
  ActivityDay fromActivitiesState(ActivitiesState activitiesState) =>
      ActivityDay(activitiesState.newActivityFromLoadedOrGiven(activity), day);
  @override
  List<Object> get props => [activity, day];
  @override
  bool get stringify => true;
}
