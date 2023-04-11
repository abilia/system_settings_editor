import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required ActivityDay activityDay,
    required this.activitiesBloc,
  }) : super(ActivityLoaded(activityDay)) {
    activitiesSubscription =
        activitiesBloc.stream.listen((_) async => _onNewState());
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesBloc activitiesBloc;

  Future<void> _onNewState() async {
    final activityRepository = activitiesBloc.activityRepository;
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
    final activities = await activitiesBloc.activityRepository.allBetween(
      activityDay.day.onlyDays(),
      activityDay.day.nextDay(),
    );
    final isDeleted = !activities.any((a) => a.id == activityDay.activity.id);
    return isDeleted;
  }

  void onActivityUpdated(Activity activity) {
    _emitActivity(activity);
    activitiesBloc.add(UpdateActivity(activity));
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
  const ActivityLoaded(ActivityDay activityDay) : super(activityDay);
}

class ActivityDeleted extends ActivityState {
  const ActivityDeleted(ActivityDay activityDay) : super(activityDay);
}
