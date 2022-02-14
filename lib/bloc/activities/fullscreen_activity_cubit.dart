import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/occasion/activity_occasion.dart';
import 'package:seagull/utils/datetime.dart';

class FullScreenActivityCubit extends Cubit<FullScreenActivityState> {
  FullScreenActivityCubit(
      {required ActivitiesBloc dayEventsCubit, required ClockBloc clockBloc})
      : super(LoadingState(time: DateTime.now())) {
    _dayEventsSubscription = dayEventsCubit.stream
        .listen((eventsState) => _emit(eventsState, state.time));
    _clockBlocSubscription =
        clockBloc.stream.listen((time) => _emit(state.activitiesState, time));
    _emit(dayEventsCubit.state, clockBloc.state);
  }

  late final StreamSubscription _dayEventsSubscription;
  late final StreamSubscription _clockBlocSubscription;

  _emit(ActivitiesState? activitiesState, DateTime time) {
    ActivityDay? ad;
    if (activitiesState is ActivitiesLoaded) {
      activitiesState.activities.toSet().forEach((activity) {
        ActivityDay activityDay = ActivityDay(activity, time.onlyDays());
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
            activityDay: ad, activitiesState: activitiesState, time: time)
        : NoActivityState(time: time));
  }

  void setCurrentActivity(ActivityDay activityDay) {
    emit(FullScreenActivityState(
        activityDay: activityDay,
        activitiesState: state.activitiesState,
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
  final ActivitiesState? activitiesState;
  final DateTime time;
  final ActivityDay? activityDay;

  const FullScreenActivityState(
      {required this.activitiesState, required this.time, this.activityDay});

  get eventsList {
    var activityOccasions = [];
    if (activitiesState is ActivitiesLoaded) {
      (activitiesState as ActivitiesLoaded)
          .activities
          .toSet()
          .forEach((activity) {
        ActivityDay ad = ActivityDay(activity, activity.startTime.onlyDays());
        ActivityOccasion ao = ad.toOccasion(time);
        bool res = ad.toOccasion(time).isCurrent ||
            ad.end.isAfter(time.subtract(const Duration(minutes: 1)));
        if (res) activityOccasions.add(ao);
      });
    }
    return activityOccasions;
  }

  @override
  List<Object?> get props => [activityDay, activitiesState, time];
}

class NoActivityState extends FullScreenActivityState {
  const NoActivityState({required time})
      : super(activitiesState: null, time: time);
}

class LoadingState extends FullScreenActivityState {
  const LoadingState({required time})
      : super(activitiesState: null, time: time);
}
