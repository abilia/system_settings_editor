import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/models/all.dart';

class NotificationBloc extends Bloc<NotificationEvent, dynamic> {
  NotificationBloc({
    required this.activityRepository,
    required this.activitiesBloc,
    required this.timerCubit,
    required this.timerDb,
    required this.settingsDb,
    required this.memoplannerSettingBloc,
  }) : super(NotificationEvent()) {
    on<NotificationEvent>(_scheduleNotifications,
        transformer: throttle(const Duration(seconds: 5)));
    _activitySubscription =
        activitiesBloc.stream.listen((_) => add(NotificationEvent()));
    _settingsSubscription =
        memoplannerSettingBloc.stream.listen((_) => add(NotificationEvent()));
    _timerSubscription =
        timerCubit.stream.listen((_) => add(NotificationEvent()));
  }

  final ActivityRepository activityRepository;
  final ActivitiesBloc activitiesBloc;
  final TimerCubit timerCubit;
  final TimerDb timerDb;
  final SettingsDb settingsDb;
  final MemoplannerSettingBloc memoplannerSettingBloc;
  late final StreamSubscription _activitySubscription;
  late final StreamSubscription _settingsSubscription;
  late final StreamSubscription _timerSubscription;

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

  @override
  Future<void> close() async {
    await _activitySubscription.cancel();
    await _settingsSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}

class NotificationEvent {}

EventTransformer<Event> throttle<Event>(Duration delay) =>
    (events, mapper) => events
        .throttleTime(delay, trailing: false, leading: true)
        .asyncExpand(mapper); // sequential