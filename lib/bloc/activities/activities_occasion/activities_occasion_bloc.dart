import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models/activity.dart';

class ActivitiesOccasionBloc
    extends Bloc<ActivitiesOccasionEvent, ActivitiesOccasionState> {
  StreamSubscription activitiesSubscription;
  StreamSubscription dayPickerSubscription;

  ActivitiesOccasionBloc(
      {@required ClockBloc clockBloc,
      @required DayActivitiesBloc dayActivitiesBloc})
      : _initialState = ActivitiesOccasionLoading(clockBloc.state) {
    activitiesSubscription = dayActivitiesBloc.listen((activitiesState) {
      if (activitiesState is DayActivitiesLoaded)
        add(ActivitiesChanged(activitiesState.filteredActivities));
    });
    dayPickerSubscription = clockBloc.listen((now) => add(NowChanged(now)));
  }
  final ActivitiesOccasionLoading _initialState;
  @override
  ActivitiesOccasionState get initialState => _initialState;

  @override
  Stream<ActivitiesOccasionState> mapEventToState(
    ActivitiesOccasionEvent event,
  ) async* {
    if (event is ActivitiesChanged) {
      yield ActivitiesOccasionLoaded(
          _mapActivitiesToActivityOccasions(event.activities, state.now),
          state.now);
    } else if (event is NowChanged) {
      if (state is ActivitiesOccasionLoaded) {
        yield ActivitiesOccasionLoaded(
            _mapActivitiesToActivityOccasions(
                (state as ActivitiesOccasionLoaded)
                    .activityStates
                    .map((a) => a.activity),
                event.now),
            event.now);
      } else
        yield ActivitiesOccasionLoading(event.now);
    }
  }

  List<ActivityOccasion> _mapActivitiesToActivityOccasions(
      Iterable<Activity> activities, DateTime now) {
    return activities.map((a) => ActivityOccasion(a, now: now)).toList()..sort((a,b) {
      return a.occasion.index.compareTo(b.occasion.index);
    });
  }

  @override
  void close() {
    activitiesSubscription.cancel();
    dayPickerSubscription.cancel();
    super.close();
  }
}
