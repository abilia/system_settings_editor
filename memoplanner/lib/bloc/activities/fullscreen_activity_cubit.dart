import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/rxdart.dart';

class FullScreenActivityCubit extends Cubit<FullScreenActivityState> {
  FullScreenActivityCubit({
    required ActivitiesBloc activitiesBloc,
    required this.activityRepository,
    required this.clockBloc,
    required AlarmCubit alarmCubit,
    required ActivityDay startingActivity,
  }) : super(
          FullScreenActivityState(
            selected: startingActivity,
          ),
        ) {
    _activityBlocSubscription = activitiesBloc.stream.listen(
      (_) async => _updateState(),
    );
    _clockBlocSubscription = clockBloc.stream.listen(
      (_) async => _updateState(),
    );
    _alarmCubitSubscription = alarmCubit.stream
        .whereType<NewAlarm>()
        .listen((alarm) => setCurrentActivity(alarm.activityDay));
  }

  final ActivityRepository activityRepository;
  final ClockBloc clockBloc;
  late final StreamSubscription _activityBlocSubscription;
  late final StreamSubscription _clockBlocSubscription;
  late final StreamSubscription _alarmCubitSubscription;

  void loadActivities() => unawaited(_updateState());

  Future<void> _updateState() async {
    final day = clockBloc.state.onlyDays();
    final activities = await activityRepository.allBetween(day, day.nextDay());
    if (isClosed) return;
    emit(
      _stateFrom(
        activities,
        clockBloc.state,
        state.selected,
      ),
    );
  }

  void setCurrentActivity(ActivityDay activityDay) {
    emit(
      FullScreenActivityState(
        selected: activityDay,
        eventsList: state.eventsList,
      ),
    );
  }

  static FullScreenActivityState _stateFrom(
    Iterable<Activity> activities,
    DateTime time,
    ActivityDay selectedActivity,
  ) {
    final day = time.onlyDays();
    final ongoingActivities = activities
        .where((a) => !a.fullDay)
        .expand((a) => a.dayActivitiesForDay(day))
        .map((ad) => ad.toOccasion(time))
        .where((activityOccasion) => activityOccasion.isCurrent)
        .toList()
      ..sort();
    final selected = ongoingActivities.firstWhereOrNull(
          (a) => a.activity.id == selectedActivity.activity.id,
        ) ??
        ongoingActivities.firstOrNull ??
        selectedActivity;
    return FullScreenActivityState(
      selected: selected,
      eventsList: UnmodifiableListView(ongoingActivities),
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
  final UnmodifiableListView<ActivityOccasion>? eventsList;

  const FullScreenActivityState({
    required this.selected,
    this.eventsList,
  });

  @override
  List<Object?> get props => [selected, eventsList];
}
