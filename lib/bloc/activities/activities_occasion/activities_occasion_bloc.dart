import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'activities_occasion_event.dart';
part 'activities_occasion_state.dart';

class ActivitiesOccasionBloc
    extends Bloc<ActivitiesOccasionEvent, ActivitiesOccasionState> {
  final DayActivitiesBloc dayActivitiesBloc;
  final ClockBloc clockBloc;
  late final StreamSubscription activitiesSubscription;
  late final StreamSubscription clockSubscription;

  ActivitiesOccasionBloc({
    required this.clockBloc,
    required this.dayActivitiesBloc,
  }) : super(ActivitiesOccasionLoading()) {
    activitiesSubscription = dayActivitiesBloc.stream.listen((activitiesState) {
      if (activitiesState is DayActivitiesLoaded) {
        add(ActivitiesChanged(activitiesState));
      }
    });
    clockSubscription = clockBloc.stream.listen((now) => add(NowChanged(now)));
  }

  @override
  Stream<ActivitiesOccasionState> mapEventToState(
    ActivitiesOccasionEvent event,
  ) async* {
    if (event is ActivitiesChanged) {
      yield _mapActivitiesToActivityOccasionsState(
        event.dayActivitiesLoadedState,
        now: clockBloc.state,
      );
    } else if (event is NowChanged) {
      final dayActivitiesState = dayActivitiesBloc.state;
      if (dayActivitiesState is DayActivitiesLoaded) {
        yield _mapActivitiesToActivityOccasionsState(
          dayActivitiesState,
          now: event.now,
        );
      } else {
        yield ActivitiesOccasionLoading();
      }
    }
  }

  ActivitiesOccasionLoaded _mapActivitiesToActivityOccasionsState(
      DayActivitiesLoaded dayActivitiesLoadedState,
      {required DateTime now}) {
    final day = dayActivitiesLoadedState.day;
    final activities = dayActivitiesLoadedState.activities;
    final occasion = dayActivitiesLoadedState.occasion;

    switch (occasion) {
      case Occasion.past:
        return createState(
          activities: activities.where(
            (a) => !a.activity.removeAfter || !a.end.isDayBefore(now),
          ),
          asActivityOccasion: (ad) => ad.toOccasion(now),
          asFulldayOccasion: (ad) => ad.toPast(),
          day: day,
          occasion: occasion,
        );
      case Occasion.future:
        return createState(
          activities: activities,
          asActivityOccasion: (ad) => ad.toOccasion(now),
          asFulldayOccasion: (ad) => ad.toFuture(),
          day: day,
          occasion: occasion,
        );
      case Occasion.current:
      default:
        return createState(
          activities: activities,
          asActivityOccasion: (ad) => ad.toOccasion(now),
          asFulldayOccasion: (ad) => ad.toFuture(),
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
        fullDayActivities: activities
            .where((ad) => ad.activity.fullDay)
            .map(asFulldayOccasion ?? asActivityOccasion)
            .toList(),
        day: day,
        occasion: occasion,
      );

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    await clockSubscription.cancel();
    return super.close();
  }
}
