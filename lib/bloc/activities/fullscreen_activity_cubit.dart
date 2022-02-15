import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/occasion/activity_occasion.dart';
import 'package:seagull/utils/datetime.dart';

class FullScreenActivityCubit extends Cubit<FullScreenActivityState> {
  FullScreenActivityCubit(
      {required ActivitiesBloc activitiesBloc,
      required ClockBloc clockBloc,
      required ActivityDay startingActivity})
      : super(
          LoadingState(
            activityDay: startingActivity,
            time: startingActivity.start,
          ),
        ) {
    _activityBlocSubscription = activitiesBloc.stream.listen(
      (activitiesState) => _emit(activitiesState, state.time),
    );
    _clockBlocSubscription = clockBloc.stream.listen(
      (time) => _emit(state.activitiesState, time),
    );
    _emit(activitiesBloc.state, clockBloc.state);
  }

  late final StreamSubscription _activityBlocSubscription;
  late final StreamSubscription _clockBlocSubscription;

  _emit(ActivitiesState? activitiesState, DateTime time) {
    ActivityDay? ad;
    if (activitiesState is ActivitiesLoaded) {
      activitiesState.activities.toSet().forEach(
        (activity) {
          ActivityDay activityDay = ActivityDay(
            activity,
            activity.startTime.onlyDays(),
          );
          ActivityOccasion oc = activityDay.toOccasion(time);
          if (oc.isCurrent ||
              !oc.activity.hasEndTime && oc.start.isAtSameMomentAs(time)) {
            ad = activityDay;
          }
        },
      );
    }
    emit(
      ad != null
          ? FullScreenActivityState(
              activityDay: ad ?? state.activityDay,
              activitiesState: activitiesState,
              time: time)
          : NoActivityState(activityDay: state.activityDay, time: time),
    );
  }

  void setCurrentActivity(ActivityDay activityDay) {
    emit(
      FullScreenActivityState(
          activityDay: activityDay,
          activitiesState: state.activitiesState,
          time: state.time),
    );
  }

  @override
  Future<void> close() async {
    await _activityBlocSubscription.cancel();
    await _clockBlocSubscription.cancel();
    return super.close();
  }
}

class FullScreenActivityState extends Equatable {
  final ActivitiesState? activitiesState;
  final DateTime time;
  final ActivityDay activityDay;

  const FullScreenActivityState(
      {this.activitiesState, required this.time, required this.activityDay});

  get eventsList {
    var activityOccasions = [];
    if (activitiesState is ActivitiesLoaded) {
      (activitiesState as ActivitiesLoaded).activities.toSet().forEach(
        (activity) {
          ActivityOccasion ao =
              ActivityDay(activity, activity.startTime.onlyDays())
                  .toOccasion(time);
          if (ao.isCurrent) activityOccasions.add(ao);
        },
      );
    }
    return activityOccasions;
  }

  @override
  List<Object?> get props => [activityDay, activitiesState, time];
}

class NoActivityState extends FullScreenActivityState {
  const NoActivityState(
      {required DateTime time, required ActivityDay activityDay})
      : super(time: time, activityDay: activityDay);
}

class LoadingState extends FullScreenActivityState {
  const LoadingState({required DateTime time, required ActivityDay activityDay})
      : super(time: time, activityDay: activityDay);
}
