import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityOccasion extends ActivityDay implements EventOccasion {
  @override
  bool get isPast => occasion.isPast;
  @override
  bool get isCurrent => occasion.isCurrent && !activity.fullDay;
  @override
  bool get isFuture => occasion.isFuture;

  bool get hasTimepillarContent => activity.hasImage || isSignedOff || isPast;

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
  String toString() => 'ActivityOccasion { ${super.toString()} $occasion }';

  @override
  int compareTo(other) => compare(other);
}

class ActivityDay extends Event {
  final DateTime day;
  final Activity activity;
  bool get isSignedOff =>
      activity.checkable &&
      activity.signedOffDates.contains(whaleDateFormat(day));

  const ActivityDay(this.activity, this.day) : super();

  @override
  ActivityOccasion toOccasion(DateTime now) => ActivityOccasion(
        activity,
        day,
        _occasion(now),
      );

  @override
  String get title => activity.title;
  @override
  DateTime get start => activity.startClock(day);
  @override
  DateTime get end => activity.endClock(day);
  @override
  int get category => activity.category;
  @override
  String get id => activity.id;
  @override
  AbiliaFile get image =>
      AbiliaFile.from(id: activity.fileId, path: activity.icon);

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
  String toString() =>
      'ActivityDay { ${activity.id} ${activity.title} ${yMd(day)} }';

  @override
  List<Object> get props => [activity, day];
}
