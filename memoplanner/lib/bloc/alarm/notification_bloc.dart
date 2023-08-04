import 'dart:async';

import 'package:file_storage/file_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/rxdart.dart';

class ScheduleNotifications {}

class NotificationState {}

class NotificationBloc extends Bloc<ScheduleNotifications, NotificationState> {
  final ActivityRepository activityRepository;
  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingsBloc memoplannerSettingBloc;
  late final StreamSubscription _daysStreamSubscription;

  NotificationBloc({
    required this.activityRepository,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
    required Duration scheduleNotificationsDelay,
    required Ticker ticker,
  }) : super(NotificationState()) {
    on<ScheduleNotifications>(
      (event, emit) async => _scheduleNotifications(),
      transformer: _debounceTime(scheduleNotificationsDelay),
    );
    _daysStreamSubscription =
        ticker.days.listen((_) => add(ScheduleNotifications()));
  }

  Future<void> _scheduleNotifications() async {
    final settings = memoplannerSettingBloc.state;
    if (settings is MemoplannerSettingsNotLoaded) return;

    final now = DateTime.now();
    final timers = await timerDb.getRunningTimersFrom(now);
    final activities = await activityRepository.allAfter(
      now.subtract(maxReminder), // subtracting to get all reminders
    );
    return scheduleNotificationsIsolated(
      NotificationsSchedulerData(
        activities: activities,
        timers: timers.toAlarm(),
        language: settingsDb.language,
        alwaysUse24HourFormat: settingsDb.alwaysUse24HourFormat,
        settings: settings.alarm,
        fileStorage: GetIt.I<FileStorage>(),
      ),
    );
  }

  EventTransformer<Event> _debounceTime<Event>(Duration time) =>
      (events, mapper) => events.debounceTime(time).asyncExpand(mapper);

  @override
  Future<void> close() async {
    await _daysStreamSubscription.cancel();
    return super.close();
  }
}
