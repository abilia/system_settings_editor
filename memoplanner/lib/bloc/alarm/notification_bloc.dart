import 'dart:async';

import 'package:calendar_events/repository/activity_repository.dart';
import 'package:file_storage/file_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull_logging/seagull_logging.dart';

class ScheduleNotifications {
  const ScheduleNotifications(this.reason);
  final String reason;
  @override
  String toString() => 'NotificationEvent ($reason)';
}

class NotificationState {
  const NotificationState();
}

class NotificationBloc extends Bloc<ScheduleNotifications, NotificationState>
    implements Info {
  NotificationBloc({
    required this.activityRepository,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
    required Duration scheduleNotificationsDelay,
    required Ticker ticker,
    required Stream<NotificationAlarm> notificationStream,
  }) : super(const NotificationState()) {
    on<ScheduleNotifications>(
      _scheduleNotifications,
      transformer: _debounceTime(scheduleNotificationsDelay),
    );
    _daysStreamSubscription =
        ticker.days.listen((_) => add(const ScheduleNotifications('new day')));
    _notificationStreamSubscription = notificationStream
        .where((notification) => notification.reschedule)
        .listen((_) =>
            add(const ScheduleNotifications('running out of notifications')));
  }

  final ActivityRepository activityRepository;
  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingsBloc memoplannerSettingBloc;
  late final StreamSubscription _notificationStreamSubscription;
  late final StreamSubscription _daysStreamSubscription;

  Future<void> _scheduleNotifications(
    ScheduleNotifications event,
    Emitter emit,
  ) async {
    if (memoplannerSettingBloc.state is MemoplannerSettingsNotLoaded) {
      await memoplannerSettingBloc.stream
          .firstWhere((s) => s is! MemoplannerSettingsNotLoaded);
    }
    final settings = memoplannerSettingBloc.state;

    final now = DateTime.now();
    final timers = await timerDb.getRunningTimersFrom(now);
    final activities = await activityRepository.allBetween(
      now.subtract(maxReminder),
      now.add(maxDepth.days()),
    );
    return scheduleNotificationsIsolated(
      NotificationsSchedulerData.fromCalendarEvents(
        activities: activities,
        timers: timers,
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
    await _notificationStreamSubscription.cancel();
    return super.close();
  }
}
