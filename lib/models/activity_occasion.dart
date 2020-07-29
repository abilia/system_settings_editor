import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

enum Occasion { past, current, future }

class ActivityOccasion extends ActivityDay {
  bool get isPast => occasion == Occasion.past;

  final Occasion occasion;
  ActivityOccasion(
    Activity activity,
    DateTime day,
    this.occasion,
  )   : assert(occasion != null),
        super(activity, day);

  @override
  ActivityOccasion fromActivitiesState(ActivitiesState activitiesState) =>
      ActivityOccasion(activitiesState.newActivityFromLoadedOrGiven(activity),
          day, occasion);

  @visibleForTesting
  factory ActivityOccasion.forTest(
    Activity activity, {
    Occasion occasion = Occasion.current,
    DateTime day,
  }) =>
      ActivityOccasion(
          activity, day ?? activity.startTime.onlyDays(), occasion);

  @override
  List<Object> get props => [occasion, ...super.props];

  @override
  int compareTo(other) {
    final occasionComparing = occasion.index.compareTo(other.occasion.index);
    if (occasionComparing != 0) return occasionComparing;
    return super.compareTo(other);
  }

  @override
  String toString() => 'ActivityOccasion { $activity ${yMd(day)} $occasion }';
}

class ActivityDay extends Equatable implements Comparable {
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
  ActivityOccasion toOccasion(DateTime now) => ActivityOccasion(
      activity,
      day,
      end.isBefore(now)
          ? Occasion.past
          : start.isAfter(now) ? Occasion.future : Occasion.current);
  ActivityOccasion toPast() => ActivityOccasion(activity, day, Occasion.past);
  ActivityOccasion toFuture() =>
      ActivityOccasion(activity, day, Occasion.future);

  @override
  List<Object> get props => [activity, day];

  @override
  String toString() => 'ActivityDay { $activity ${yMd(day)} }';

  @override
  int compareTo(other) {
    final starTimeComparing = start.compareTo(other.start);
    if (starTimeComparing != 0) return starTimeComparing;
    return end.compareTo(other.end);
  }
}
