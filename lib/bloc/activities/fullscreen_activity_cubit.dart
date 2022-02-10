import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/occasion/activity_occasion.dart';

class FullScreenActivityCubit extends Cubit<FullScreenActivityState> {
  FullScreenActivityCubit(
      {required DayEventsCubit dayEventsCubit, required ClockBloc clockBloc})
      : super(LoadingState(time: DateTime.now())) {
    _dayEventsSubscription = dayEventsCubit.stream
        .listen((eventsState) => _emit(eventsState, state.time));
    _clockBlocSubscription =
        clockBloc.stream.listen((time) => _emit(state.eventsState, time));
    _emit(dayEventsCubit.state, clockBloc.state);
  }

  late final StreamSubscription _dayEventsSubscription;
  late final StreamSubscription _clockBlocSubscription;

  _emit(EventsState? eventsState, DateTime time) {
    ActivityDay? ad;
    if (eventsState is EventsLoaded) {
      eventsState.activities.toSet().forEach((activityDay) {
        ActivityOccasion oc = activityDay.toOccasion(time);
        if (oc.isCurrent ||
            oc.isPast &&
                !oc.activity.hasEndTime &&
                oc.start.isAfter(time.subtract(const Duration(minutes: 1)))) {
          ad = activityDay;
        }
      });
    }
    emit(ad != null
        ? FullScreenActivityState(
            activityDay: ad, eventsState: eventsState, time: time)
        : NoActivityState(time: time));
  }

  get eventsList => state.eventsState is EventsLoaded
      ? (state.eventsState as EventsLoaded).activities.where((activity) =>
          activity.toOccasion(state.time).isCurrent ||
          activity.end.isAfter(state.time.subtract(const Duration(minutes: 1))))
      : [];

  void setCurrentActivity(ActivityDay activityDay) {
    emit(FullScreenActivityState(
        activityDay: activityDay,
        eventsState: state.eventsState,
        time: state.time));
  }

  @override
  Future<void> close() async {
    await _dayEventsSubscription.cancel();
    await _clockBlocSubscription.cancel();
    return super.close();
  }
}

class FullScreenActivityState extends Equatable {
  final EventsState? eventsState;
  final DateTime time;
  final ActivityDay? activityDay;

  const FullScreenActivityState(
      {required this.eventsState, required this.time, this.activityDay});

  @override
  List<Object?> get props => [activityDay, eventsState, time];
}

class NoActivityState extends FullScreenActivityState {
  const NoActivityState({required time}) : super(eventsState: null, time: time);
}

class LoadingState extends FullScreenActivityState {
  const LoadingState({required time}) : super(eventsState: null, time: time);
}
