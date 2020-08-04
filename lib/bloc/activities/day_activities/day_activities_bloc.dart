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
            ? DayActivitiesLoaded(
                (activitiesBloc.state as ActivitiesLoaded).activities,
                dayPickerBloc.state.day)
            : DayActivitiesUninitialized()) {
    _activitiesSubscription = activitiesBloc.listen((state) {
      final activityState = state;
      if (activityState is ActivitiesLoaded) {
        add(UpdateActivities(activityState.activities));
      }
    });
    _dayPickerSubscription =
        dayPickerBloc.listen((state) => add(UpdateDay(state.day)));
  }

  @override
  Stream<DayActivitiesState> mapEventToState(DayActivitiesEvent event) async* {
    if (event is UpdateDay) {
      final activityState = activitiesBloc.state;
      if (activityState is ActivitiesLoaded) {
        yield DayActivitiesLoaded(activityState.activities, event.dayFilter);
      }
    } else if (event is UpdateActivities) {
      yield DayActivitiesLoaded(event.activities, dayPickerBloc.state.day);
    }
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    return super.close();
  }
}
