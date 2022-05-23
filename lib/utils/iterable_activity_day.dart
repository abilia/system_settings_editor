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
