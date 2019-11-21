import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models/activity.dart';

class ActivitiesOccasionBloc
    extends Bloc<ActivitiesOccasionEvent, ActivitiesOccasionState> {
  StreamSubscription activitiesSubscription;
  StreamSubscription clockSubscription;

  ActivitiesOccasionBloc({
    @required ClockBloc clockBloc,
    @required DayActivitiesBloc dayActivitiesBloc,
  }) : _initialState = ActivitiesOccasionLoading(
            clockBloc.state, dayActivitiesBloc.state.dayFilter) {
    activitiesSubscription = dayActivitiesBloc.listen((activitiesState) {
      if (activitiesState is DayActivitiesLoaded)
        add(ActivitiesChanged(
            activitiesState.activities, activitiesState.dayFilter));
    });
    clockSubscription = clockBloc.listen((now) => add(NowChanged(now)));
  }
  final ActivitiesOccasionLoading _initialState;
  @override
  ActivitiesOccasionState get initialState => _initialState;

  @override
  Stream<ActivitiesOccasionState> mapEventToState(
    ActivitiesOccasionEvent event,
  ) async* {
    if (event is ActivitiesChanged) {
      yield _mapActivitiesToActivityOccasionsState(
        event.activities,
        now: state.now,
        day: event.day,
      );
    } else if (event is NowChanged) {
      if (state is ActivitiesOccasionLoaded) {
        final loadedState = state as ActivitiesOccasionLoaded;
        yield _mapActivitiesToActivityOccasionsState(
            loadedState.activities
                .followedBy(loadedState.fullDayActivities)
                .map((a) => a.activity),
            now: event.now,
            day: loadedState.day);
      } else
        yield ActivitiesOccasionLoading(event.now, state.day);
    }
  }

  ActivitiesOccasionLoaded _mapActivitiesToActivityOccasionsState(
    Iterable<Activity> activities, {
    @required DateTime now,
    @required DateTime day,
  }) {
    return ActivitiesOccasionLoaded(
      activities: activities
          .where((a) => !a.fullDay)
          .map((a) => ActivityOccasion(a, now: now, day: day))
          .toList()
            ..sort((a, b) {
              final occasionComparing =
                  a.occasion.index.compareTo(b.occasion.index);
              if (occasionComparing != 0) return occasionComparing;
              final starTimeComparing = a.activity
                  .startClock(now)
                  .compareTo(b.activity.startClock(now));
              if (starTimeComparing != 0) return starTimeComparing;
              return a.activity
                  .endClock(now)
                  .compareTo(b.activity.endClock(now));
            }),
      fullDayActivities: activities
          .where((a) => a.fullDay)
          .map((a) => ActivityOccasion.fullDay(a, now: now, day: day))
          .toList(),
      now: now,
      day: day,
    );
  }

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    await clockSubscription.cancel();
    return super.close();
  }
}
