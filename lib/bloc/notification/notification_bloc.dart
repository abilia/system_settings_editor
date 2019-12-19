import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/models.dart';
import './bloc.dart';
import 'package:seagull/utils.dart';

class NotificationBloc extends Bloc<NotificationEvent, AlarmStateBase> {
  final ActivitiesBloc activitiesBloc;
  StreamSubscription _selectedNotificationSubscription;
  StreamSubscription _canSoundAlarmSubscription;

  NotificationBloc({
    @required this.activitiesBloc,
    @required Stream<String> selectedNotificationStream,
  }) {
    _selectedNotificationSubscription = selectedNotificationStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (String data, EventSink<Payload> sink) {
          try {
            sink.add(Payload.fromJson(json.decode(data)));
          } catch (_) {}
        },
      ),
    ).listen((payload) => add(NotificationSelected(payload)));

    _canSoundAlarmSubscription = activitiesBloc.listen(
      (activitiesState) {
        final state = this.state;
        if (activitiesState is ActivitiesLoaded && state is PendingAlarmState) {
          for (final pending in state.pedingAlarms) {
            add(NotificationSelected(pending));
          }
        }
      },
    );
  }

  @override
  AlarmStateBase get initialState => UnInitializedAlarmState();

  @override
  Stream<AlarmStateBase> mapEventToState(
    NotificationEvent event,
  ) async* {
    final currentState = state;
    final activitiesState = activitiesBloc.state;
    if (activitiesState is ActivitiesLoaded && event is NotificationSelected) {
      final payload = event.payload;
      final activityId = payload.activityId;
      final activity = activitiesState.activities
          .firstWhere((a) => a.id == activityId, orElse: () => null);
      if (activity != null) {
        if (payload.reminder > 0) {
          yield AlarmState(
            NewReminder(
              activity,
              reminder: payload.reminder.minutes(),
            ),
          );
        } else {
          yield AlarmState(
            NewAlarm(
              activity,
              alarmOnStart: event.payload.onStart,
            ),
          );
        }
      }
    } else if (event is NotificationSelected) {
      if (currentState is PendingAlarmState) {
        yield PendingAlarmState(currentState.pedingAlarms..add(event.payload));
      } else {
        yield PendingAlarmState([event.payload]);
      }
    }
  }

  @override
  Future<void> close() async {
    await _selectedNotificationSubscription.cancel();
    await _canSoundAlarmSubscription.cancel();
    return super.close();
  }
}
