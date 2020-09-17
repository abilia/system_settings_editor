import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class NotificationBloc extends Bloc<NotificationAlarm, AlarmStateBase> {
  static final _log = Logger((NotificationBloc).toString());
  StreamSubscription _selectedNotificationSubscription;

  NotificationBloc({
    @required ReplaySubject<String> selectedNotificationSubject,
  }) : super(UnInitializedAlarmState()) {
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
    ).listen((payload) => add(payload));
  }

  @override
  Stream<AlarmStateBase> mapEventToState(
    NotificationAlarm payload,
  ) async* {
    yield AlarmState(payload);
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    return super.close();
  }
}
