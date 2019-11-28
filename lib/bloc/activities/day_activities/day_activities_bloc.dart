import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

class DayActivitiesBloc extends Bloc<DayActivitiesEvent, DayActivitiesState> {
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  StreamSubscription _activitiesSubscription;
  StreamSubscription _dayPickerSubscription;

  DayActivitiesBloc(
      {@required this.activitiesBloc, @required this.dayPickerBloc}) {
    _activitiesSubscription = activitiesBloc.listen((state) {
      if (state is ActivitiesLoaded) {
        add(UpdateActivities(
            (activitiesBloc.state as ActivitiesLoaded).activities));
      }
    });
    _dayPickerSubscription =
        dayPickerBloc.listen((state) => add(UpdateDay(state)));
  }

  @override
  DayActivitiesState get initialState {
    final activitiesState = activitiesBloc.state;
    if (activitiesState is ActivitiesLoaded) {
      final dayActivities = _mapActivitiesToCurrentDayActivities(
          activitiesState.activities, dayPickerBloc.state);
      return DayActivitiesLoaded(dayActivities, dayPickerBloc.state);
    } else {
      return DayActivitiesUninitialized();
    }
  }

  @override
  Stream<DayActivitiesState> mapEventToState(DayActivitiesEvent event) async* {
    if (event is UpdateDay) {
      yield* _mapUpdateFilterToState(event);
    } else if (event is UpdateActivities) {
      yield* _mapActivitiesUpdatedToState(event, dayPickerBloc.state);
    }
  }

  Stream<DayActivitiesState> _mapUpdateFilterToState(
    UpdateDay event,
  ) async* {
    if (activitiesBloc.state is ActivitiesLoaded) {
      yield DayActivitiesLoaded(
          _mapActivitiesToCurrentDayActivities(
            (activitiesBloc.state as ActivitiesLoaded).activities,
            event.dayFilter,
          ),
          event.dayFilter);
    }
  }

  Stream<DayActivitiesState> _mapActivitiesUpdatedToState(
      UpdateActivities event, DateTime dayFilter) async* {
    final dayActivities =
        _mapActivitiesToCurrentDayActivities(event.activities, dayFilter);
    yield DayActivitiesLoaded(dayActivities, dayFilter);
  }

  Iterable<Activity> _mapActivitiesToCurrentDayActivities(
      Iterable<Activity> ativities, DateTime filterDay) {
    return ativities
        .where((activity) => !activity.deleted)
        .where((activity) => Recurs.shouldShowForDay(activity, filterDay));
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    return super.close();
  }
}
