import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NotificationBloc extends Bloc<NotificationPayload, AlarmStateBase> {
  final ActivitiesBloc activitiesBloc;
  StreamSubscription _selectedNotificationSubscription;
  StreamSubscription _canSoundAlarmSubscription;

  NotificationBloc({
    @required this.activitiesBloc,
    @required Stream<String> selectedNotificationStream,
  }) {
    _selectedNotificationSubscription = selectedNotificationStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (String data, EventSink<NotificationPayload> sink) {
          try {
            sink.add(NotificationPayload.fromJson(json.decode(data)));
          } catch (_) {}
        },
      ),
    ).listen((payload) => add(payload));

    _canSoundAlarmSubscription = activitiesBloc.listen(
      (activitiesState) {
        final state = this.state;
        if (activitiesState is ActivitiesLoaded && state is PendingAlarmState) {
          state.pedingAlarms.forEach((p) => add(p));
        }
      },
    );
  }

  @override
  AlarmStateBase get initialState => UnInitializedAlarmState();

  @override
  Stream<AlarmStateBase> mapEventToState(
    NotificationPayload payload,
  ) async* {
    final activitiesState = activitiesBloc.state;
    if (activitiesState is ActivitiesLoaded) {
      final activity = activitiesState.activities
          .firstWhere((a) => a.id == payload.activityId);
      yield AlarmState(_getAlarm(activity, payload));
    } else {
      yield PendingAlarmState(_pendings(state, payload));
    }
  }

  NotificationAlarm _getAlarm(Activity activity, NotificationPayload payload) {
    if (payload.reminder > 0) {
      return NewReminder(activity, reminder: payload.reminder.minutes());
    }
    return NewAlarm(activity, alarmOnStart: payload.onStart);
  }

  List<NotificationPayload> _pendings(AlarmStateBase currentState, NotificationPayload payload) {
    if (currentState is PendingAlarmState) {
      return currentState.pedingAlarms..add(payload);
    }
    return [payload];
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    await _canSoundAlarmSubscription.cancel();
    return super.close();
  }
}
