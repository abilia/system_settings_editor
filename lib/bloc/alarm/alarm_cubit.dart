import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription _clockSubscription;
  late final StreamSubscription _selectedNotificationSubscription;
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  final MemoplannerSettingBloc settingsBloc;

  AlarmCubit({
    required Stream<NotificationAlarm> selectedNotificationSubject,
    required this.activitiesBloc,
    required this.clockBloc,
    required this.settingsBloc,
  }) : super(null) {
    _selectedNotificationSubscription =
        selectedNotificationSubject.listen((payload) => emit(payload));
    _clockSubscription = clockBloc.stream.listen((now) => _newMinute(now));
  }

  void _newMinute(DateTime now) {
    if (settingsBloc.state.alarm.disabledUntilDate.isAfter(clockBloc.state)) {
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
    return super.close();
  }
}
