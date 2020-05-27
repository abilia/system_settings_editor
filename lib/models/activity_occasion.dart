import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

enum Occasion { past, current, future }

class ActivityOccasion extends ActivityDay {
  final Occasion occasion;
  ActivityOccasion._(Activity activity, this.occasion, DateTime day)
      : super(activity, day);
  ActivityOccasion(
    ActivityDay ad, {
    @required DateTime now,
  })  : occasion = ad.activity.endClock(ad.day).isBefore(now)
            ? Occasion.past
            : ad.activity.startClock(ad.day).isAfter(now)
                ? Occasion.future
                : Occasion.current,
        super.copy(ad);

  @visibleForTesting
  factory ActivityOccasion.forTest(
    Activity activity, {
    Occasion occasion = Occasion.current,
    DateTime day,
  }) =>
      ActivityOccasion._(
          activity, occasion, day ?? activity.startTime.onlyDays());

  factory ActivityOccasion.fullDay(
    ActivityDay ad, {
    @required DateTime now,
  }) =>
      ActivityOccasion._(
          ad.activity,
          ad.activity.startClock(ad.day).isDayBefore(now)
              ? Occasion.past
              : Occasion.future,
          ad.day);

  @override
  List<Object> get props => [occasion, ...super.props];
}

class ActivityDay extends Equatable {
  final DateTime day;
  final Activity activity;
  DateTime get start => activity.startClock(day);
  DateTime get end => activity.endClock(day);
  ActivityDay(this.activity, this.day);
  ActivityDay.copy(ActivityDay ad) : this(ad.activity, ad.day);
  @override
  List<Object> get props => [activity, day];
  @override
  bool get stringify => true;
}
