import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class NotificationCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription _selectedNotificationSubscription;

  NotificationCubit({
    required ReplaySubject<NotificationAlarm> selectedNotificationSubject,
  }) : super(null) {
    _selectedNotificationSubscription =
        selectedNotificationSubject.listen((payload) => emit(payload));
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    return super.close();
  }
}
