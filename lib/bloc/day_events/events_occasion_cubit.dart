import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'events_occasion_state.dart';

class EventsOccasionCubit extends Cubit<EventsOccasionState> {
  final DayEventsCubit dayEventsCubit;

  late final StreamSubscription activitiesSubscription;

  EventsOccasionCubit({
    required this.dayEventsCubit,
  }) : super(const EventsOccasionLoading()) {
    activitiesSubscription = dayEventsCubit.stream
        .whereType<DayEventsLoaded>()
        .listen(_onEventsChanged);
  }

  void _onEventsChanged(DayEventsLoaded dayEventsLoadedState) => emit(
        mapActivitiesToActivityOccasionsState(
          dayActivities: dayEventsLoadedState.activities,
          dayTimers: dayEventsLoadedState.timers,
          day: dayEventsLoadedState.day,
          occasion: dayEventsLoadedState.occasion,
        ),
      );

  @override
  Future<void> close() async {
    await super.close();
    await activitiesSubscription.cancel();
  }
}

EventsOccasionLoaded mapActivitiesToActivityOccasionsState({
  required List<ActivityDay> dayActivities,
  required List<TimerDay> dayTimers,
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
        timers: dayTimers,
        day: day,
        dayOccasion: occasion,
      );
    case Occasion.future:
    case Occasion.current:
    default:
      return _createState(
        activities: dayActivities,
        timers: dayTimers,
        day: day,
        dayOccasion: occasion,
      );
  }
}

EventsOccasionLoaded _createState({
  required Iterable<ActivityDay> activities,
  required List<TimerDay> timers,
  required DateTime day,
  required Occasion dayOccasion,
  bool fulldays = true,
}) {
  final timedActivities =
      activities.where((activityDay) => !activityDay.activity.fullDay).toList();

  final fullDayOccasion =
      dayOccasion == Occasion.past ? Occasion.past : Occasion.future;
  return EventsOccasionLoaded(
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
