import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class NotificationBloc extends Bloc<NotificationEvent, String> {
  NotificationBloc({
    required this.activityRepository,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
    required SyncDelays syncDelays,
  }) : super('init') {
    on<NotificationEvent>(_scheduleNotifications,
        transformer: _throttle(syncDelays.betweenSync));
  }

  final ActivityRepository activityRepository;

  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingsBloc memoplannerSettingBloc;

  Future _scheduleNotifications(
    NotificationEvent event,
    Emitter emit,
  ) async {
    final settings = memoplannerSettingBloc.state;
    if (settings is MemoplannerSettingsNotLoaded) return;

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