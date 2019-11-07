import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';

class DayActivitiesBloc
    extends Bloc<DayActivitiesEvent, DayActivitiesState> {
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
    return activitiesBloc.state is ActivitiesLoaded
        ? DayActivitiesLoaded(
            (activitiesBloc.state as ActivitiesLoaded).activities,
            dayPickerBloc.state,
          )
        : DayActivitiesLoading(dayPickerBloc.state);
  }

  @override
  Stream<DayActivitiesState> mapEventToState(
      DayActivitiesEvent event) async* {
    if (event is UpdateDay) {
      yield* _mapUpdateFilterToState(event);
    } else if (event is UpdateActivities) {
      yield* _mapActivitiesUpdatedToState(event);
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
        event.dayFilter,
      );
    }
  }

  Stream<DayActivitiesState> _mapActivitiesUpdatedToState(
    UpdateActivities event,
  ) async* {
    yield DayActivitiesLoaded(
      _mapActivitiesToCurrentDayActivities(
        event.activities,
        state.dayFilter,
      ),
      dayPickerBloc.state,
    );
  }

  Iterable<Activity> _mapActivitiesToCurrentDayActivities(
      Iterable<Activity> ativities, DateTime filter) {
    final filterDay = DateTime(filter.year, filter.month, filter.day);
    return ativities.where((activity) {
      final activityTime = activity.startDate;
      final activityDay =
          DateTime(activityTime.year, activityTime.month, activityTime.day);
      return filterDay.isAtSameMomentAs(activityDay);
    });
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    return super.close();
  }
}
