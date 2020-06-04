import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

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
      if (activitiesState is DayActivitiesLoaded) {
        add(ActivitiesChanged(activitiesState.activities, activitiesState.day));
      }
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
            loadedState.activities.followedBy(loadedState.fullDayActivities),
            now: event.now,
            day: dayPickerBloc.state.day);
      } else {
        yield ActivitiesOccasionLoading();
      }
    }
  }

  ActivitiesOccasionLoaded _mapActivitiesToActivityOccasionsState(
    Iterable<ActivityDay> activities, {
    @required DateTime now,
    @required DateTime day,
  }) {
    final removeAfterFiltered = activities
        .where((a) => !(a.activity.removeAfter && a.end.isDayBefore(now)))
        .toList();

    final timedActivities = removeAfterFiltered
        .where((ad) => !ad.activity.fullDay)
        .map((ad) => ad.toOccasion(now))
        .toList()
          ..sort((a, b) {
            final occasionComparing =
                a.occasion.index.compareTo(b.occasion.index);
            if (occasionComparing != 0) return occasionComparing;
            final starTimeComparing = a.start.compareTo(b.start);
            if (starTimeComparing != 0) return starTimeComparing;
            return a.end.compareTo(b.end);
          });
    final fullDayActivities = removeAfterFiltered
        .where((ad) => ad.activity.fullDay)
        .map((a) => ActivityOccasion.fullDay(a, now: now))
        .toList();

    final isToday = day.isAtSameDay(now);

    return ActivitiesOccasionLoaded(
      activities: timedActivities,
      fullDayActivities: fullDayActivities,
      day: day,
      occasion: isToday
          ? Occasion.current
          : day.isAfter(now) ? Occasion.future : Occasion.past,
    );
  }

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    await clockSubscription.cancel();
    return super.close();
  }
}
