import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class NotificationBloc extends Bloc<NotificationPayload, AlarmStateBase> {
  static final _log = Logger((NotificationBloc).toString());
  final ActivitiesBloc activitiesBloc;
  StreamSubscription _selectedNotificationSubscription;
  StreamSubscription _canSoundAlarmSubscription;

  NotificationBloc({
    @required this.activitiesBloc,
    @required Stream<String> selectedNotificationStream,
  }) : super(UnInitializedAlarmState()) {
    _selectedNotificationSubscription = selectedNotificationStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (String data, EventSink<NotificationPayload> sink) {
          try {
            sink.add(NotificationPayload.fromJson(json.decode(data)));
          } catch (e) {
            _log.severe(
                'Failed to parse selected notification payload: $data', e);
          }
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
  Stream<AlarmStateBase> mapEventToState(
    NotificationPayload payload,
  ) async* {
    final activitiesState = activitiesBloc.state;
    if (activitiesState is ActivitiesLoaded) {
      final activity = activitiesState.activities
          .firstWhere((a) => a.id == payload.activityId, orElse: () => null);
      if (activity != null) {
        yield AlarmState(payload.getAlarm(activity));
        return;
      }
    }
    yield PendingAlarmState(_pendings(state, payload));
  }

  Iterable<NotificationPayload> _pendings(
    AlarmStateBase currentState,
    NotificationPayload payload,
  ) {
    if (currentState is PendingAlarmState) {
      if (currentState.pedingAlarms.contains(payload)) {
        return currentState.pedingAlarms;
      }
      return [...currentState.pedingAlarms, payload];
    }
    return {payload};
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    await _canSoundAlarmSubscription.cancel();
    return super.close();
  }
}
