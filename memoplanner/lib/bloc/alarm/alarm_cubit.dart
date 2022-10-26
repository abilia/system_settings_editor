import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription _clockSubscription;
  late final StreamSubscription _selectedNotificationSubscription;
  late final StreamSubscription _timerSubscription;
  final ActivityRepository activityRepository;
  final MemoplannerSettingsBloc settingsBloc;

  AlarmCubit({
    required Stream<NotificationAlarm> selectedNotificationSubject,
    required Stream<TimerAlarm> timerAlarm,
    required this.activityRepository,
    required this.settingsBloc,
    required ClockBloc clockBloc,
  }) : super(null) {
    _selectedNotificationSubscription =
        selectedNotificationSubject.listen((payload) => emit(payload));
    _clockSubscription = clockBloc.stream.listen((now) => _newMinute(now));
    _timerSubscription = timerAlarm.listen(emit);
  }

  Future<void> _newMinute(DateTime now) async {
    if (settingsBloc.state.alarm.disabledUntilDate.isAfter(now)) {
      return;
    }
    final activities = await activityRepository.allBetween(
      now.previousDay(),
      now.add(maxReminder),
    );
    final alarmsAndReminders = activities.alarmsOnExactMinute(now);
    for (final alarm in alarmsAndReminders) {
      emit(alarm);
    }
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _selectedNotificationSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}
