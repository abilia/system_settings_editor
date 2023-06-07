import 'dart:async';

import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/background/notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationEvent {}

class NotificationBloc extends Bloc<NotificationEvent, String> {
  final ActivityRepository activityRepository;

  NotificationBloc({
    required this.activityRepository,
    required Duration scheduleNotificationsDelay,
  }) : super('init') {
    on<NotificationEvent>(
      (event, emit) async => _scheduleNotifications(),
      transformer: _debounceTime(scheduleNotificationsDelay),
    );
  }

  Future<void> _scheduleNotifications() async {
    final now = DateTime.now();
    final activities = await activityRepository.allAfter(now);
    return scheduleActivityNotifications(activities);
  }

  EventTransformer<Event> _debounceTime<Event>(Duration time) =>
      (events, mapper) => events.debounceTime(time).asyncExpand(mapper);
}
