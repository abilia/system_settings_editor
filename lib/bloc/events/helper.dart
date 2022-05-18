import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

EventsLoaded mapToEventsState({
  required List<ActivityDay> dayActivities,
  required List<TimerOccasion> timerOccasions,
  required Occasion occasion,
  required DateTime day,
  bool includeFullday = true,
}) {
  switch (occasion) {
    case Occasion.past:
      return _createState(
        activities: dayActivities.where(
          (activity) =>
              !activity.activity.removeAfter || occasion != Occasion.past,
        ),
        timers: timerOccasions,
        day: day,
        dayOccasion: occasion,
      );
    case Occasion.future:
    case Occasion.current:
    default:
      return _createState(
        activities: dayActivities,
        timers: timerOccasions,
        day: day,
        dayOccasion: occasion,
      );
  }
}

EventsLoaded _createState({
  required Iterable<ActivityDay> activities,
  required List<TimerOccasion> timers,
  required DateTime day,
  required Occasion dayOccasion,
  bool fulldays = true,
}) {
  final timedActivities =
      activities.where((activityDay) => !activityDay.activity.fullDay).toList();

  final fullDayOccasion = dayOccasion.isPast ? Occasion.past : Occasion.future;
  return EventsLoaded(
    activities: timedActivities,
    timers: timers,
    fullDayActivities: fulldays
        ? activities
            .where((activityDay) => activityDay.activity.fullDay)
            .map((e) => ActivityOccasion(e.activity, day, fullDayOccasion))
            .toList()
        : [],
    day: day,
    occasion: dayOccasion,
  );
}
