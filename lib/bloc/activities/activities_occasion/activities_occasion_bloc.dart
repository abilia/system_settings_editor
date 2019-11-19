import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models/activity.dart';

class ActivitiesOccasionBloc
    extends Bloc<ActivitiesOccasionEvent, ActivitiesOccasionState> {
  StreamSubscription activitiesSubscription;
  StreamSubscription clockSubscription;

  ActivitiesOccasionBloc(
      {@required ClockBloc clockBloc,
      @required DayActivitiesBloc dayActivitiesBloc})
      : _initialState = ActivitiesOccasionLoading(clockBloc.state) {
    activitiesSubscription = dayActivitiesBloc.listen((activitiesState) {
      if (activitiesState is DayActivitiesLoaded)
        add(ActivitiesChanged(activitiesState.activities));
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
      yield _mapActivitiesToActivityOccasionsState(event.activities,
          now: state.now);
    } else if (event is NowChanged) {
      if (state is ActivitiesOccasionLoaded) {
        final loadedState = state as ActivitiesOccasionLoaded;
        yield _mapActivitiesToActivityOccasionsState(
            loadedState.activities
                .followedBy(loadedState.fullDayActivities)
                .map((a) => a.activity),
            now: event.now);
      } else
        yield ActivitiesOccasionLoading(event.now);
    }
  }

  ActivitiesOccasionLoaded _mapActivitiesToActivityOccasionsState(
      Iterable<Activity> activities,
      {@required DateTime now}) {
    return ActivitiesOccasionLoaded(
        activities: activities
            .where((a) => !a.fullDay)
            .map((a) => ActivityOccasion(a, now: now))
            .toList()
              ..sort((a, b) {
                final occasionComparing =
                    a.occasion.index.compareTo(b.occasion.index);
                if (occasionComparing != 0) return occasionComparing;

                final starTimeComparing =
                    a.activity.startDate.compareTo(b.activity.startDate);
                if (starTimeComparing != 0) return starTimeComparing;
                return a.activity.endDate.compareTo(b.activity.endDate);
              }),
        fullDayActivities: activities
            .where((a) => a.fullDay)
            .map((a) => ActivityOccasion.fullDay(a, now: now))
            .toList(),
        now: now);
  }

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    await clockSubscription.cancel();
    return super.close();
  }
}
