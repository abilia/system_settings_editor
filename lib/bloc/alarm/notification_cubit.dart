import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class NotificationCubit extends Cubit<NotificationAlarm?> {
  static final _log = Logger((NotificationCubit).toString());
  late final StreamSubscription _selectedNotificationSubscription;

  NotificationCubit({
    required ReplaySubject<String> selectedNotificationSubject,
  }) : super(null) {
    _selectedNotificationSubscription = selectedNotificationSubject.transform(
      StreamTransformer.fromHandlers(
        handleData: (String data, EventSink<NotificationAlarm> sink) {
          try {
            sink.add(NotificationAlarm.decode(data));
          } catch (e) {
            _log.severe(
                'Failed to parse selected notification payload: $data', e);
          }
        },
      ),
    ).listen((payload) => emit(payload));
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    return super.close();
  }
}
