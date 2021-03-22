import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_activities_event.dart';
part 'day_activities_state.dart';

class DayActivitiesBloc extends Bloc<DayActivitiesEvent, DayActivitiesState> {
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  StreamSubscription _activitiesSubscription;
  StreamSubscription _dayPickerSubscription;

  DayActivitiesBloc(
      {@required this.activitiesBloc, @required this.dayPickerBloc})
      : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                (activitiesBloc.state as ActivitiesLoaded).activities,
                dayPickerBloc.state.day,
                dayPickerBloc.state.occasion,
              )
            : DayActivitiesUninitialized()) {
    _activitiesSubscription = activitiesBloc.listen((state) {
      final activityState = state;
      if (activityState is ActivitiesLoaded) {
        add(UpdateActivities(activityState.activities));
      }
    });
    _dayPickerSubscription = dayPickerBloc
        .listen((state) => add(UpdateDay(state.day, state.occasion)));
  }

  @override
  Stream<DayActivitiesState> mapEventToState(DayActivitiesEvent event) async* {
    if (event is UpdateDay) {
      final activityState = activitiesBloc.state;
      if (activityState is ActivitiesLoaded) {
        yield _mapToState(
          activityState.activities,
          event.dayFilter,
          event.occasion,
        );
      }
    } else if (event is UpdateActivities) {
      yield _mapToState(
        event.activities,
        dayPickerBloc.state.day,
        dayPickerBloc.state.occasion,
      );
    }
  }

  static DayActivitiesState _mapToState(
    final Iterable<Activity> activities,
    final DateTime day,
    final Occasion occasion,
  ) =>
      DayActivitiesLoaded(
        activities.expand((activity) => activity.dayActivitiesForDay(day)),
        day,
        occasion,
      );

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    return super.close();
  }
}
