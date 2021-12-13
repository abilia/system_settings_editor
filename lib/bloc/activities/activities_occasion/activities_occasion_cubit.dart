import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'activities_occasion_state.dart';

class ActivitiesOccasionCubit extends Cubit<ActivitiesOccasionState> {
  final DayActivitiesBloc dayActivitiesBloc;
  final ClockBloc clockBloc;
  late final StreamSubscription activitiesSubscription;
  late final StreamSubscription clockSubscription;

  ActivitiesOccasionCubit({
    required this.clockBloc,
    required this.dayActivitiesBloc,
  }) : super(const ActivitiesOccasionLoading()) {
    activitiesSubscription = dayActivitiesBloc.stream
        .whereType<DayActivitiesLoaded>()
        .listen(_onActivitiesChanged);
    clockSubscription = clockBloc.stream.listen(_onNowChanged);
  }

  void _onNowChanged(DateTime now) {
    final dayActivitiesState = dayActivitiesBloc.state;
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
          (a) => !a.activity.removeAfter || !a.end.isDayBefore(now),
        ),
        asActivityOccasion: (ad) => ad.toOccasion(now),
        asFulldayOccasion: includeFullday ? (ad) => ad.toPast() : null,
        day: day,
        occasion: occasion,
      );
    case Occasion.future:
      return createState(
        activities: dayActivities,
        asActivityOccasion: (ad) => ad.toOccasion(now),
        asFulldayOccasion: includeFullday ? (ad) => ad.toFuture() : null,
        day: day,
        occasion: occasion,
      );
    case Occasion.current:
    default:
      return createState(
        activities: dayActivities,
        asActivityOccasion: (ad) => ad.toOccasion(now),
        asFulldayOccasion: includeFullday ? (ad) => ad.toFuture() : null,
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
          .where((ad) => !ad.activity.fullDay)
          .map(asActivityOccasion)
          .toList()
        ..sort(),
      fullDayActivities: asFulldayOccasion != null
          ? activities
              .where((ad) => ad.activity.fullDay)
              .map(asFulldayOccasion)
              .toList()
          : [],
      day: day,
      occasion: occasion,
    );
