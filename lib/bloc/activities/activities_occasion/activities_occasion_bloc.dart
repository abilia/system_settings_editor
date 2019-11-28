import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models/activity.dart';

class ActivitiesOccasionBloc
    extends Bloc<ActivitiesOccasionEvent, ActivitiesOccasionState> {
  DayPickerBloc dayPickerBloc;
  ClockBloc clockBloc;
  StreamSubscription activitiesSubscription;
  StreamSubscription clockSubscription;

  ActivitiesOccasionBloc({
    @required this.clockBloc,
    @required DayActivitiesBloc dayActivitiesBloc,
    @required this.dayPickerBloc,
  }) : _initialState = ActivitiesOccasionLoading() {
    activitiesSubscription = dayActivitiesBloc.listen((activitiesState) {
      if (activitiesState is DayActivitiesLoaded)
        add(ActivitiesChanged(activitiesState.activities, activitiesState.day));
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
        now: clockBloc.state,
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
            day: dayPickerBloc.state);
      } else
        yield ActivitiesOccasionLoading();
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
