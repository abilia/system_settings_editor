import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required ActivityDay activityDay,
    required this.activitiesBloc,
  }) : super(ActivityState(activityDay)) {
    activitiesSubscription = activitiesBloc.stream.listen((event) {
      _onNewState(event.activities);
    });
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesBloc activitiesBloc;

  Future<void> _onNewState(List<Activity> activities) async {
    final found = activities.firstWhere((a) => a.id == state.activityDay.id,
        orElse: () => state.activityDay.activity);
    final day =
        found.isRecurring ? state.activityDay.day : found.startTime.onlyDays();
    emit(ActivityState(ActivityDay(found, day)));
  }

  void onActivityUpdated(Activity activity) {
    final day = activity.isRecurring
        ? state.activityDay.day
        : activity.startTime.onlyDays();
    emit(ActivityState(ActivityDay(activity, day)));
    activitiesBloc.add(UpdateActivity(activity));
  }

  @override
  Future<void> close() async {
    await activitiesSubscription.cancel();
    return super.close();
  }
}

class ActivityState extends Equatable {
  const ActivityState(this.activityDay);
  final ActivityDay activityDay;

  @override
  List<Object?> get props => [activityDay];
}
