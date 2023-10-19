import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:equatable/equatable.dart';
import 'package:utils/utils.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required ActivityDay activityDay,
    required this.activitiesCubit,
  }) : super(ActivityLoaded(activityDay)) {
    activitiesSubscription =
        activitiesCubit.stream.listen((_) async => _onNewState());
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesCubit activitiesCubit;

  Future<void> _onNewState() async {
    final activityRepository = activitiesCubit.activityRepository;
    final found = await activityRepository.getById(state.activityDay.id);
    final isDeleted = await _checkIfDeleted();
    if (isClosed) {
      return;
    }
    if (isDeleted || found == null) {
      return emit(ActivityDeleted(state.activityDay));
    }
    _emitActivity(found);
  }

  Future<bool> _checkIfDeleted() async {
    final activityDay = state.activityDay;
    final activities = await activitiesCubit.activityRepository.allBetween(
      activityDay.day.onlyDays(),
      activityDay.day.nextDay(),
    );
    final isDeleted = !activities.any((a) => a.id == activityDay.activity.id);
    return isDeleted;
  }

  Future<void> onActivityUpdated(Activity activity) {
    _emitActivity(activity);
    return activitiesCubit.addActivity(activity);
  }

  void _emitActivity(Activity activity) {
    final day = activity.isRecurring
        ? state.activityDay.day
        : activity.startTime.onlyDays();
    emit(ActivityLoaded(ActivityDay(activity, day)));
  }

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    return super.close();
  }
}

abstract class ActivityState extends Equatable {
  const ActivityState(this.activityDay);
  final ActivityDay activityDay;

  @override
  List<Object?> get props => [activityDay];
}

class ActivityLoaded extends ActivityState {
  const ActivityLoaded(super.activityDay);
}

class ActivityDeleted extends ActivityState {
  const ActivityDeleted(super.activityDay);
}
