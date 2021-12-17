import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'activities_occasion_state.dart';

class ActivitiesOccasionCubit extends Cubit<ActivitiesOccasionState> {
  final DayActivitiesCubit dayActivitiesCubit;
  final ClockBloc clockBloc;
  late final StreamSubscription activitiesSubscription;
  late final StreamSubscription clockSubscription;

  ActivitiesOccasionCubit({
    required this.clockBloc,
    required this.dayActivitiesCubit,
  }) : super(const ActivitiesOccasionLoading()) {
    activitiesSubscription = dayActivitiesCubit.stream
        .whereType<DayActivitiesLoaded>()
        .listen(_onActivitiesChanged);
    clockSubscription = clockBloc.stream.listen(_onNowChanged);
  }

  void _onNowChanged(DateTime now) {
    final dayActivitiesState = dayActivitiesCubit.state;
    if (dayActivitiesState is DayActivitiesLoaded) {
      emit(
        mapActivitiesToActivityOccasionsState(
          dayActivities: dayActivitiesState.activities,
          day: dayActivitiesState.day,
          occasion: dayActivitiesState.occasion,
          now: clockBloc.state,
        ),
      );
    }
  }

  void _onActivitiesChanged(DayActivitiesLoaded dayActivitiesLoadedState) =>
      emit(
        mapActivitiesToActivityOccasionsState(
          dayActivities: dayActivitiesLoadedState.activities,
          day: dayActivitiesLoadedState.day,
          occasion: dayActivitiesLoadedState.occasion,
          now: clockBloc.state,
        ),
      );

  @override
  Future<void> close() async {
    await super.close();
    await activitiesSubscription.cancel();
    await clockSubscription.cancel();
  }
}

ActivitiesOccasionLoaded mapActivitiesToActivityOccasionsState({
  required List<ActivityDay> dayActivities,
  required Occasion occasion,
  required DateTime now,
  required DateTime day,
  bool includeFullday = true,
}) {
  switch (occasion) {
    case Occasion.past:
      return createState(
        activities: dayActivities.where(
          (activity) =>
              !activity.activity.removeAfter || !activity.end.isDayBefore(now),
        ),
        asActivityOccasion: (activityDay) => activityDay.toOccasion(now),
        asFulldayOccasion:
            includeFullday ? (activityDay) => activityDay.toPast() : null,
        day: day,
        occasion: occasion,
      );
    case Occasion.future:
      return createState(
        activities: dayActivities,
        asActivityOccasion: (activityDay) => activityDay.toOccasion(now),
        asFulldayOccasion:
            includeFullday ? (activityDay) => activityDay.toFuture() : null,
        day: day,
        occasion: occasion,
      );
    case Occasion.current:
    default:
      return createState(
        activities: dayActivities,
        asActivityOccasion: (activityDay) => activityDay.toOccasion(now),
        asFulldayOccasion:
            includeFullday ? (activityDay) => activityDay.toFuture() : null,
        day: day,
        occasion: occasion,
      );
  }
}

ActivitiesOccasionLoaded createState({
  required Iterable<ActivityDay> activities,
  required DateTime day,
  required Occasion occasion,
  required ActivityOccasion Function(ActivityDay) asActivityOccasion,
  ActivityOccasion Function(ActivityDay)? asFulldayOccasion,
}) =>
    ActivitiesOccasionLoaded(
      activities: activities
          .where((activityDay) => !activityDay.activity.fullDay)
          .map(asActivityOccasion)
          .toList()
        ..sort(),
      fullDayActivities: asFulldayOccasion != null
          ? activities
              .where((activityDay) => activityDay.activity.fullDay)
              .map(asFulldayOccasion)
              .toList()
          : [],
      day: day,
      occasion: occasion,
    );
