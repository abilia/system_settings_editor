import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';

class FilteredActivitiesBloc
    extends Bloc<FilteredActivitiesEvent, FilteredActivitiesState> {
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  StreamSubscription activitiesSubscription;
  StreamSubscription dayPickerSubscription;
  final DateTime currentTime = DateTime.now();

  FilteredActivitiesBloc(
      {@required this.activitiesBloc, @required this.dayPickerBloc}) {
    activitiesSubscription = activitiesBloc.listen((state) {
      if (state is ActivitiesLoaded) {
        add(UpdateActivities(
            (activitiesBloc.state as ActivitiesLoaded).activities));
      }
    });
    dayPickerSubscription =
        dayPickerBloc.listen((state) => add(UpdateFilter(state)));
  }

  @override
  FilteredActivitiesState get initialState {
    return activitiesBloc.state is ActivitiesLoaded
        ? FilteredActivitiesLoaded(
            (activitiesBloc.state as ActivitiesLoaded).activities,
            currentTime,
          )
        : FilteredActivitiesLoading();
  }

  @override
  Stream<FilteredActivitiesState> mapEventToState(
      FilteredActivitiesEvent event) async* {
    if (event is UpdateFilter) {
      yield* _mapUpdateFilterToState(event);
    } else if (event is UpdateActivities) {
      yield* _mapActivitiesUpdatedToState(event);
    }
  }

  Stream<FilteredActivitiesState> _mapUpdateFilterToState(
    UpdateFilter event,
  ) async* {
    if (activitiesBloc.state is ActivitiesLoaded) {
      yield FilteredActivitiesLoaded(
        _mapActivitiesToFilteredActivities(
          (activitiesBloc.state as ActivitiesLoaded).activities,
          event.dayFilter,
        ),
        event.dayFilter,
      );
    }
  }

  Stream<FilteredActivitiesState> _mapActivitiesUpdatedToState(
    UpdateActivities event,
  ) async* {
    final visibilityFilter = state is FilteredActivitiesLoaded
        ? (state as FilteredActivitiesLoaded).dayFilter
        : currentTime;
    yield FilteredActivitiesLoaded(
      _mapActivitiesToFilteredActivities(
        (activitiesBloc.state as ActivitiesLoaded).activities,
        visibilityFilter,
      ),
      visibilityFilter,
    );
  }

  List<Activity> _mapActivitiesToFilteredActivities(
      List<Activity> ativities, DateTime filter) {
    final filterDay = DateTime(filter.year, filter.month, filter.day);
    return ativities.where((activity) {
      final activityTime = activity.startDate;
      final activityDay =
          DateTime(activityTime.year, activityTime.month, activityTime.day);
      return filterDay.isAtSameMomentAs(activityDay);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  void close() {
    activitiesSubscription.cancel();
    dayPickerSubscription.cancel();
    super.close();
  }
}
