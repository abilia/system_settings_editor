import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

extension ActivitiesExtensions on Iterable<Activity> {
  bool anyConflictWith(Activity activity) {
    if (activity.fullDay) return false;
    if (activity.isRecurring) return false;

    final day = activity.startTime.onlyDays();
    final activityDay = ActivityDay(activity, day);

    final valids = where((a) => !a.fullDay).where((a) => a.id != activity.id);

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
