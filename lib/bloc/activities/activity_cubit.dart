import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityCubit extends Cubit<ActivityDay> {
  ActivityCubit({
    required ActivityDay activityDay,
    required this.activitiesBloc,
  }) : super(activityDay) {
    activitiesSubscription = activitiesBloc.stream.listen((event) {
      _onNewState(event.activities);
    });
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesBloc activitiesBloc;

  Future<void> _onNewState(List<Activity> activities) async {
    final found = activities.firstWhere((a) => a.id == state.id,
        orElse: () => state.activity);
    final day =
        found.isRecurring ? state.day : found.startTime.onlyDays();
    emit(ActivityDay(found, day));
  }

  void onActivityUpdated(Activity activity) {
    final day = activity.isRecurring
        ? state.day
        : activity.startTime.onlyDays();
    emit(ActivityDay(activity, day));
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
