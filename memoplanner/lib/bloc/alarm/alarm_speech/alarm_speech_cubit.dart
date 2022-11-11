import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/repository/all.dart';

enum AlarmSpeechState { unplayed, played }

class AlarmSpeechCubit extends Cubit<AlarmSpeechState> {
  static const minSpeechDelay = Duration(milliseconds: 4500);

  final _log = Logger((AlarmSpeechCubit).toString());
  final NewAlarm alarm;
  final SoundBloc soundBloc;

  late final StreamSubscription<ActivityAlarm?>? _notificationSubscription;
  late final StreamSubscription<Touch> _touchSubscription;
  late final StreamSubscription<SoundState> _speechSubscription;
  late final StreamSubscription _delayedSubscription;
  late final StreamSubscription<RemoteMessage> _remoteMessageSubscription;

  AlarmSpeechCubit({
    required this.alarm,
    required this.soundBloc,
    required DateTime Function() now,
    required AlarmSettings alarmSettings,
    required Stream<Touch> touchStream,
    required Stream<RemoteMessage> remoteMessageStream,
    Stream<NotificationAlarm>? selectedNotificationStream,
  }) : super(AlarmSpeechState.unplayed) {
    _log.fine('$alarm');
    final timeFromAlarmStart = now().difference(alarm.notificationTime);
    final timeUntilSpeech = _alarmDuration(alarmSettings) - timeFromAlarmStart;
    _log.info('until speech time: $timeUntilSpeech');

    _delayedSubscription =
        Stream.fromFuture(Future.delayed(timeUntilSpeech)).listen(_maybePlay);

    _touchSubscription = touchStream.take(1).listen(_maybePlay);

    _notificationSubscription = selectedNotificationStream
        ?.where((event) => event is ActivityAlarm)
        .cast<ActivityAlarm>()
        .where((notificationAlarm) => notificationAlarm == alarm)
        .listen(_maybePlay);

    _speechSubscription = soundBloc.stream
        .whereType<SoundPlaying>()
        .take(1)
        .listen((_) => emit(AlarmSpeechState.played));

    _remoteMessageSubscription = remoteMessageStream
        .where((p) =>
            (p.data.containsKey(RemoteAlarm.stopSoundKey) ||
                p.data.containsKey(RemoteAlarm.popKey)) &&
            p.stopAlarmSoundKey == alarm.hashCode)
        .listen(_maybePlay);
  }

  Future<void> _maybePlay(parameter) async {
    _log.fine('maybePlay $parameter');
    if (state == AlarmSpeechState.unplayed) {
      final playNow =
          parameter is! ActivityAlarm || !await _notificationActive();
      if (playNow) {
        _log.fine('playing AlarmSpeech');
        emit(AlarmSpeechState.played);
        soundBloc.add(PlaySound(alarm.speech));
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
      return alarmSettings.duration < iOSPersistentNotificationMaxDuration
          ? alarmSettings.duration
          : iOSPersistentNotificationMaxDuration;
    }

    return alarmSettings.duration;
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    await _speechSubscription.cancel();
    await _delayedSubscription.cancel();
    await _touchSubscription.cancel();
    await _remoteMessageSubscription.cancel();
    return super.close();
  }
}
