import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required ActivityDay ad,
    required this.activitiesBloc,
  }) : super(ActivityState(ad)) {
    activitiesSubscription = activitiesBloc.stream.listen((event) {
      _onNewState(event.activities);
    });
  }
  late final StreamSubscription activitiesSubscription;
  final ActivitiesBloc activitiesBloc;

  Future<void> _onNewState(List<Activity> activities) async {
    final found = activities.firstWhere((a) => a.id == state.activityDay.id);
    emit(ActivityState(ActivityDay(found, state.activityDay.day)));
  }

  void onActivityUpdated(Activity activity) {
    emit(ActivityState(ActivityDay(activity, state.activityDay.day)));
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
