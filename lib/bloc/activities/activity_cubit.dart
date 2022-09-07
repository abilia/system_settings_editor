import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required ActivityDay activityDay,
    required this.activitiesBloc,
  }) : super(ActivityLoaded(activityDay)) {
    activitiesSubscription = activitiesBloc.stream.listen((_) => _onNewState());
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesBloc activitiesBloc;

  void _onNewState() async {
    final found =
        await activitiesBloc.activityRepository.getById(state.activityDay.id);
    if (found == null || found.deleted) {
      return emit(ActivityDeleted(state.activityDay));
    }
    _emitActivity(found);
  }

  void onActivityUpdated(Activity activity) async {
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
