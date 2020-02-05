import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';

class DayActivitiesBloc extends Bloc<DayActivitiesEvent, DayActivitiesState> {
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  StreamSubscription _activitiesSubscription;
  StreamSubscription _dayPickerSubscription;

  DayActivitiesBloc(
      {@required this.activitiesBloc, @required this.dayPickerBloc}) {
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
  DayActivitiesState get initialState {
    final activitiesState = activitiesBloc.state;
    if (activitiesState is ActivitiesLoaded) {
      return DayActivitiesLoaded(
          activitiesState.activities, dayPickerBloc.state.day);
    } else {
      return DayActivitiesUninitialized();
    }
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
