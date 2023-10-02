import 'dart:async';

import 'package:calendar_events/models/all.dart';
import 'package:calendar_events/repository/all.dart';
import 'package:calendar_events/utils/all.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:utils/utils.dart';

class AlarmCubit extends Cubit<ActivityDay?> {
  late final StreamSubscription _clockSubscription;
  final ActivityRepository activityRepository;

  AlarmCubit({
    required this.activityRepository,
    required ClockCubit clockCubit,
  }) : super(null) {
    _clockSubscription =
        clockCubit.stream.listen((now) async => _newMinute(now));
  }

  Future<void> _newMinute(DateTime now) async {
    final activities = await activityRepository.allBetween(now, now);
    final day = now.onlyDays();
    final startTimeAlarms = activities
        .where((a) => !a.fullDay)
        .expand(
          (a) => a.dayActivitiesForDay(
            day,
            includeMidnight: true,
          ),
        )
        .where((ad) => ad.activity.alarm.shouldAlarm)
        .where((a) => a.start.isAtSameMomentAs(now));

    for (final alarm in startTimeAlarms) {
      emit(alarm);
    }
  }

  // Todo: remove this
  void fakeAlarm(ActivityDay activityDay) {
    emit(activityDay);
    emit(null);
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
