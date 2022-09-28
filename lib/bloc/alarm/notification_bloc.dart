import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NotificationBloc extends Bloc<NotificationEvent, String> {
  NotificationBloc({
    required this.activityRepository,
    required this.activitiesBloc,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
    required SyncDelays syncDelays,
  }) : super('init') {
    on<NotificationEvent>(_scheduleNotifications,
        transformer: _throttle(syncDelays.betweenSync));
  }

  final ActivityRepository activityRepository;
  final ActivitiesBloc activitiesBloc;
  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingsBloc memoplannerSettingBloc;

  Future _scheduleNotifications(
    NotificationEvent event,
    Emitter emit,
  ) async {
    final activitiesState = activitiesBloc.state;
    final settings = memoplannerSettingBloc.state;
    if (settings is MemoplannerSettingsNotLoaded ||
        activitiesState is! ActivitiesLoaded) return;

    final now = DateTime.now();
    final timers = await timerDb.getRunningTimersFrom(now);
    final activities = await activityRepository.allAfter(
      now.subtract(maxReminder), // subtracting to get all reminders
    );
    await scheduleAlarmNotificationsIsolated(
      activities: activities,
      timers: timers.toAlarm(),
      language: settingsDb.language,
      alwaysUse24HourFormat: settingsDb.alwaysUse24HourFormat,
      settings: settings.alarm,
      fileStorage: GetIt.I<FileStorage>(),
    );
  }
}

class NotificationEvent {}

EventTransformer<Event> _throttle<Event>(Duration delay) =>
    (events, mapper) => events
        .throttleTime(delay, trailing: true, leading: false)
        .asyncExpand(mapper);
