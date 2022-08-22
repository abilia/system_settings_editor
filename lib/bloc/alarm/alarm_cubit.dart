import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription _clockSubscription;
  late final StreamSubscription _selectedNotificationSubscription;
  late final StreamSubscription _timerSubscription;
  final ActivitiesBloc activitiesBloc;
  final MemoplannerSettingBloc settingsBloc;

  AlarmCubit({
    required Stream<NotificationAlarm> selectedNotificationSubject,
    required Stream<TimerAlarm> timerAlarm,
    required this.activitiesBloc,
    required this.settingsBloc,
    required ClockBloc clockBloc,
  }) : super(null) {
    _selectedNotificationSubscription =
        selectedNotificationSubject.listen((payload) => emit(payload));
    _clockSubscription = clockBloc.stream.listen((now) => _newMinute(now));
    _timerSubscription = timerAlarm.listen(emit);
  }

  void _newMinute(DateTime now) {
    if (settingsBloc.state.alarm.disabledUntilDate.isAfter(now)) {
      return;
    }
    final state = activitiesBloc.state;
    if (state is ActivitiesLoaded) {
      final alarmsAndReminders = state.activities.alarmsOnExactMinute(now);
      for (final alarm in alarmsAndReminders) {
        emit(alarm);
      }
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
