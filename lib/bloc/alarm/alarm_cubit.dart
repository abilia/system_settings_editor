import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription? _clockSubscription;
  late final StreamSubscription _selectedNotificationSubscription;
  final ActivitiesBloc activitiesBloc;

  AlarmCubit({
    required ReplaySubject<NotificationAlarm> selectedNotificationSubject,
    required this.activitiesBloc,
    required ClockBloc clockBloc,
  }) : super(null) {
    _selectedNotificationSubscription =
        selectedNotificationSubject.listen((payload) => emit(payload));
    if (!Platform.isAndroid) {
      _clockSubscription = clockBloc.stream.listen((now) => _newMinute(now));
    }
  }

  void _newMinute(DateTime now) {
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
    await _clockSubscription?.cancel();
    await _selectedNotificationSubscription.cancel();
    return super.close();
  }
}
