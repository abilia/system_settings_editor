import 'dart:async';

import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/background/notifications.dart';
import 'package:rxdart/rxdart.dart';

class ScheduleNotifications {}

class NotificationState {}

class NotificationBloc extends Bloc<ScheduleNotifications, NotificationState> {
  final ActivitiesBloc activitiesBloc;
  late final StreamSubscription _activitiesSubscription;

  NotificationBloc({
    required this.activitiesBloc,
    required Duration scheduleNotificationsDelay,
  }) : super(NotificationState()) {
    on<ScheduleNotifications>(
      (event, emit) async => _scheduleNotifications(),
      transformer: _debounceTime(scheduleNotificationsDelay),
    );
    _activitiesSubscription =
        activitiesBloc.stream.listen((_) async => add(ScheduleNotifications()));
  }

  Future<void> _scheduleNotifications() async {
    final now = DateTime.now();
    final activities = await activitiesBloc.getActivitiesAfter(now);
    return scheduleActivityNotifications(activities);
  }

  EventTransformer<Event> _debounceTime<Event>(Duration time) =>
      (events, mapper) => events.debounceTime(time).asyncExpand(mapper);

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    return super.close();
  }
}
