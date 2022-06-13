import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

enum AlarmSpeechState { unplayed, played }

class AlarmSpeechCubit extends Cubit<AlarmSpeechState> {
  static const minSpeechDelay = Duration(milliseconds: 3500);

  final _log = Logger((AlarmSpeechCubit).toString());
  final NewAlarm alarm;
  final SoundCubit soundCubit;

  late final StreamSubscription<ActivityAlarm?>? _notificationSubscription;
  late final StreamSubscription<Touch> _touchSubscription;
  late final StreamSubscription<SoundState> _speechSubscription;
  late final StreamSubscription _delayedSubscription;

  AlarmSpeechCubit({
    required this.alarm,
    required this.soundCubit,
    required DateTime Function() now,
    required AlarmSettings alarmSettings,
    required Stream<Touch> touchStream,
    Stream<NotificationAlarm>? selectedNotificationStream,
  }) : super(AlarmSpeechState.unplayed) {
    _log.fine('$alarm');
    _log.fine('notificationTime: ${alarm.notificationTime}');
    _log.fine('alarm duration : ${alarmSettings.duration}');
    final realDuration = _alarmDuration(alarmSettings);
    _log.fine('real alarm duration : $realDuration');
    final _now = now();
    _log.fine('now : $_now');
    final timeFromAlarmStart = _now.difference(alarm.notificationTime);
    _log.fine('time from alarm start : $timeFromAlarmStart');
    final timeUntilSpeech = realDuration - timeFromAlarmStart;
    _log.info('until speech time: $timeUntilSpeech');

    _delayedSubscription =
        Stream.fromFuture(Future.delayed(timeUntilSpeech)).listen(_maybePlay);

    _touchSubscription = touchStream.take(1).listen(_maybePlay);

    _notificationSubscription = selectedNotificationStream
        ?.where((event) => event is ActivityAlarm)
        .cast<ActivityAlarm>()
        .where((notificationAlarm) => notificationAlarm == alarm)
        .listen(_maybePlay);

    _speechSubscription = soundCubit.stream
        .whereType<SoundPlaying>()
        .take(1)
        .listen((_) => emit(AlarmSpeechState.played));
  }

  Future<void> _maybePlay(parameter) async {
    _log.fine('maybePlay $parameter');
    if (state == AlarmSpeechState.unplayed) {
      final playNow =
          parameter is! ActivityAlarm || !await _notificationActive();
      if (playNow) {
        _log.fine('playing AlarmSpeech');
        emit(AlarmSpeechState.played);
        soundCubit.play(alarm.speech);
      } else {
        _log.finer('has ongoing notification, ignoring');
      }
    }
  }

  Future<bool> _notificationActive() async => (await notificationPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.getActiveNotifications() ??
          [])
      .any((n) => n.id == alarm.hashCode);

  Duration _alarmDuration(AlarmSettings alarmSettings) {
    final noAlarm = !alarm.activity.alarm.sound;
    if (noAlarm) {
      return Duration.zero;
    }

    final shortAlarm =
        Platform.isIOS && alarm.sound(alarmSettings) == Sound.Default ||
            alarmSettings.alarmDuration == AlarmDuration.alert;

    if (shortAlarm) {
      return minSpeechDelay;
    }

    if (Platform.isIOS) {
      return alarmSettings.duration < iOSPersistantNotificationMaxDuration
          ? alarmSettings.duration
          : iOSPersistantNotificationMaxDuration;
    }

    return alarmSettings.duration;
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    await _speechSubscription.cancel();
    await _delayedSubscription.cancel();
    await _touchSubscription.cancel();
    return super.close();
  }
}
