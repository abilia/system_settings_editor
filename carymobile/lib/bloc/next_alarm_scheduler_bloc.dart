import 'dart:async';

import 'package:calendar_events/models/all.dart';
import 'package:calendar_events/repository/activity_repository.dart';
import 'package:carymessenger/utils/find_next_alarm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_logging/seagull_logging.dart';
import 'package:utils/utils.dart';

class ScheduleNextAlarm {
  const ScheduleNextAlarm(this.reason);
  final String reason;
  @override
  String toString() => 'NotificationEvent ($reason)';
}

class NextAlarmSchedulerBloc extends Bloc<ScheduleNextAlarm, ActivityDay?>
    implements Info {
  NextAlarmSchedulerBloc({
    required this.activityRepository,
    required Duration scheduleNotificationsDelay,
    required Ticker ticker,
    required Stream rescheduleStream,
  }) : super(null) {
    on<ScheduleNextAlarm>(
      _scheduleNotifications,
      transformer: _debounceTime(scheduleNotificationsDelay),
    );
    _rescheduleStreamSubscription = rescheduleStream
        .listen((_) => add(const ScheduleNextAlarm('From listener')));
  }

  final ActivityRepository activityRepository;

  late final StreamSubscription _rescheduleStreamSubscription;

  Future<void> _scheduleNotifications(
    ScheduleNextAlarm event,
    Emitter emit,
  ) async {
    final now = DateTime.now().nextMinute().onlyMinutes();
    final activities = await activityRepository.allAfter(now);
    final nextAlarm = findNextAlarm(activities, now);
    emit(nextAlarm);
  }

  EventTransformer<Event> _debounceTime<Event>(Duration time) =>
      (events, mapper) => events.debounceTime(time).asyncExpand(mapper);

  @override
  Future<void> close() async {
    await _rescheduleStreamSubscription.cancel();
    return super.close();
  }
}
