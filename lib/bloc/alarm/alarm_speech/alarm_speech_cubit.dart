import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmSpeechCubit extends Cubit<AlarmSpeechState> {
  static const minSpeechDelay = Duration(milliseconds: 4500);

  final _log = Logger((AlarmSpeechCubit).toString());
  final NewAlarm alarm;
  final SoundCubit soundCubit;

  late final StreamSubscription<ActivityAlarm?> _notificationSubscription;
  late final StreamSubscription<SoundState> _speechSubscription;
  late final StreamSubscription _delayedSubscription;

  AlarmSpeechCubit({
    required this.alarm,
    required this.soundCubit,
    required AlarmSettings alarmSettings,
    required Stream<NotificationAlarm> selectedNotificationStream,
  }) : super(const AlarmSpeechUnplayed()) {
    _log.fine('$alarm');
    final speechDelay = _alarmDuration(alarmSettings);

    _log.fine('alarm length: $speechDelay');

    _delayedSubscription =
        Stream.fromFuture(Future.delayed(speechDelay)).listen(_maybePlay);

    _notificationSubscription = selectedNotificationStream
        .where((event) => event is ActivityAlarm)
        .cast<ActivityAlarm>()
        .where((notificationAlarm) => notificationAlarm == alarm)
        .listen(_maybePlay);

    _speechSubscription = soundCubit.stream
        .whereType<SoundPlaying>()
        .take(1)
        .listen((_) => emit(const AlarmSpeechPlayed()));
  }

  Future<void> _maybePlay(parameter) async {
    _log.fine('maybePlay $parameter');
    if (state is AlarmSpeechUnplayed) {
      final playNow =
          parameter is! ActivityAlarm || !await _notificationActive();
      if (playNow) {
        _log.fine('playing AlarmSpeech');
        emit(const AlarmSpeechPlayed());
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
      return maxDuration(alarmSettings.duration, iOSMaxAlarmDuration);
    }

    return alarmSettings.duration;
  }

  @override
  Future<void> close() async {
    await _notificationSubscription.cancel();
    await _speechSubscription.cancel();
    await _delayedSubscription.cancel();
    return super.close();
  }
}

abstract class AlarmSpeechState extends Equatable {
  const AlarmSpeechState();
  @override
  List<Object> get props => [];
}

class AlarmSpeechUnplayed extends AlarmSpeechState {
  const AlarmSpeechUnplayed();
}

class AlarmSpeechPlayed extends AlarmSpeechState {
  const AlarmSpeechPlayed();
}
