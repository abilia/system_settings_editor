import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class FullScreenActivityCubit extends Cubit<FullScreenActivityState> {
  FullScreenActivityCubit({
    required this.activitiesBloc,
    required this.clockBloc,
    required AlarmCubit alarmCubit,
    required ActivityDay startingActivity,
  }) : super(
          _stateFrom(
            activitiesBloc.state,
            clockBloc.state,
            startingActivity,
          ),
        ) {
    _activityBlocSubscription = activitiesBloc.stream.listen(
      (activitiesState) => _emit(activitiesState, clockBloc.state),
    );
    _clockBlocSubscription = clockBloc.stream.listen(
      (time) => _emit(activitiesBloc.state, time),
    );
    _alarmCubitSubscription = alarmCubit.stream
        .whereType<NewAlarm>()
        .listen((alarm) => setCurrentActivity(alarm.activityDay));
  }

  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  late final StreamSubscription _activityBlocSubscription;
  late final StreamSubscription _clockBlocSubscription;
  late final StreamSubscription _alarmCubitSubscription;

  void _emit(ActivitiesState activitiesState, DateTime time) =>
      emit(_stateFrom(activitiesState, time, state.selected));

  void setCurrentActivity(ActivityDay activityDay) {
    emit(
      FullScreenActivityState(
        selected: activityDay,
        eventsList: state.eventsList,
      ),
    );
  }

  static FullScreenActivityState _stateFrom(
    ActivitiesState activitiesState,
    DateTime time,
    ActivityDay selectedActivity,
  ) {
    final day = time.onlyDays();
    final ongoingActivities = activitiesState.activities
        .where((a) => !a.fullDay)
        .expand((a) => a.dayActivitiesForDay(day))
        .map((ad) => ad.toOccasion(time))
        .where((ao) => ao.isCurrent)
        .toList()
      ..sort();
    final selected = ongoingActivities.firstWhereOrNull(
          (a) => a.activity.id == selectedActivity.activity.id,
        ) ??
        ongoingActivities.firstOrNull ??
        selectedActivity;
    return FullScreenActivityState(
      selected: selected,
      eventsList: ongoingActivities,
    );
  }

  @override
  Future<void> close() async {
    await _activityBlocSubscription.cancel();
    await _clockBlocSubscription.cancel();
    await _alarmCubitSubscription.cancel();
    return super.close();
  }
}

class FullScreenActivityState extends Equatable {
  final ActivityDay selected;
  final UnmodifiableListView<ActivityOccasion> eventsList;

  FullScreenActivityState({
    required this.selected,
    required List<ActivityOccasion> eventsList,
  }) : eventsList = UnmodifiableListView(eventsList);

  @override
  List<Object?> get props => [selected, eventsList];
}
