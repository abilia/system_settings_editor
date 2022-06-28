import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

extension ActivitiesStateExtensions on ActivitiesState {
  Activity newActivityFromLoadedOrGiven(Activity activity) =>
      activities.firstWhere((a) => a.id == activity.id, orElse: () => activity);

  bool anyConflictWith(Activity activity) {
    if (activity.fullDay) return false;
    if (activity.isRecurring) return false;

    final day = activity.startTime.onlyDays();
    final activityDay = ActivityDay(activity, day);

    final valids =
        activities.where((a) => !a.fullDay).where((a) => a.id != activity.id);

    final startDayConflict = valids
        .expand((activity) => activity.dayActivitiesForDay(day))
        .any(activityDay.conflictsWith);

    if (startDayConflict) {
      return true;
    }

    final endSameDayAsStart = activityDay.start.isAtSameDay(activityDay.end);
    if (!endSameDayAsStart) {
      final nextDay = day.nextDay();
      final endConflicts = valids
          .expand((activity) => activity.dayActivitiesForDay(nextDay))
          .any(activityDay.conflictsWith);
      return endConflicts;
    }

    return false;
  }

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
