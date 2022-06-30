import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/models/all.dart';

class NotificationBloc extends Bloc<NotificationEvent, String> {
  NotificationBloc({
    required this.activityRepository,
    required this.activitiesBloc,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
  }) : super('init') {
    on<NotificationEvent>(_scheduleNotifications,
        transformer: throttle(const Duration(seconds: 5)));
  }

  final ActivityRepository activityRepository;
  final ActivitiesBloc activitiesBloc;
  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingBloc memoplannerSettingBloc;

  Future _scheduleNotifications(
    NotificationEvent event,
    Emitter emit,
  ) async {
    final activitiesState = activitiesBloc.state;
    final settingsState = memoplannerSettingBloc.state;
    if (settingsState is! MemoplannerSettingsNotLoaded &&
        activitiesState is ActivitiesLoaded) {
      final timers = await timerDb.getRunningTimersFrom(
        DateTime.now(),
      );
      final now = DateTime.now();
      final activities = await activityRepository.allAfter(now);
      await scheduleAlarmNotificationsIsolated(
        activities: activities,
        timers: timers.toAlarm(),
        language: settingsDb.language,
        alwaysUse24HourFormat: settingsDb.alwaysUse24HourFormat,
        settings: settingsState.settings.alarm,
        fileStorage: GetIt.I<FileStorage>(),
      );
    }
  }
}

class NotificationEvent {}

EventTransformer<Event> throttle<Event>(Duration delay) =>
    (events, mapper) => events
        .throttleTime(delay, trailing: false, leading: true)
        .asyncExpand(mapper);
