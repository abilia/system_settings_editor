import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityOccasion extends ActivityDay implements EventOccasion<Activity> {
  bool get isPast => occasion == Occasion.past;
  bool get isCurrent => occasion == Occasion.current && !activity.fullDay;

  @override
  final Occasion occasion;
  const ActivityOccasion(
    Activity activity,
    DateTime day,
    this.occasion,
  ) : super(activity, day);

  @override
  List<Object> get props => [occasion, ...super.props];

  @override
  String toString() =>
      'ActivityOccasion { ${activity.id} ${activity.title} ${yMd(day)} $occasion }';
}

class ActivityDay extends EventDay<Activity> {
  Activity get activity => event;
  bool get isSignedOff =>
      activity.checkable &&
      activity.signedOffDates.contains(whaleDateFormat(day));

  const ActivityDay(Activity activity, DateTime day) : super(activity, day);

  ActivityDay.copy(ActivityDay ad) : this(ad.activity, ad.day);
  @override
  ActivityOccasion toOccasion(DateTime now) => ActivityOccasion(
        activity,
        day,
        _occasion(now),
      );

  Occasion _occasion(DateTime now) {
    if (activity.fullDay) {
      if (day.isAtSameDay(now)) return Occasion.current;
      if (day.isAfter(now)) return Occasion.future;
      return Occasion.past;
    }
    if (end.isBefore(now)) return Occasion.past;
    if (start.isAfter(now)) return Occasion.future;
    return Occasion.current;
  }

  @override
  String toString() => 'ActivityDay { $activity ${yMd(day)} }';
}
