import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

extension ActivityDayFilter on Iterable<ActivityDay> {
  Iterable<ActivityDay> removeAfter(DateTime now) =>
      where((ad) => !(ad.activity.removeAfter && ad.end.isDayBefore(now)));

  Iterable<ActivityDay> removeAfterOccasion(Occasion occasion) =>
      occasion == Occasion.past
          ? where((ad) => !ad.activity.removeAfter)
          : this;
}

extension ActivityDayConflict on ActivityDay {
  bool conflictsWith(ActivityDay ad) => activity.hasEndTime
      ? ad.start.inInclusiveRange(
            startDate: start,
            endDate: end,
          ) ||
          ad.end.inInclusiveRange(
            startDate: start,
            endDate: end,
          )
      : start.inInclusiveRange(
            startDate: ad.start,
            endDate: ad.end,
          ) ||
          end.inInclusiveRange(
            startDate: ad.start,
            endDate: ad.end,
          );
}
