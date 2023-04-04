import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:memoplanner/bloc/sound/sound_bloc.dart';

import 'package:memoplanner/models/all.dart';

part 'alarm_sound_event.dart';

class AlarmSoundBloc extends Bloc<AlarmSoundEvent, Sound?> {
  final AudioPlayer audioPlayer;
  late final StreamSubscription onPlayerCompletion;

  AlarmSoundBloc()
      : audioPlayer = AudioPlayer(),
        super(null) {
    on<AlarmSoundEvent>(_onEvent,
        transformer: _throttle(SoundBloc.spamProtectionDelay));
    onPlayerCompletion = audioPlayer.onPlayerComplete
        .listen((_) => add(const AlarmSoundCompleted()));
  }

  AudioContext _getAudioContext([bool asAlarm = true]) => AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: asAlarm ? AndroidUsageType.alarm : AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: const AudioContextIOS(
          category: AVAudioSessionCategory.multiRoute,
          options: [
            AVAudioSessionOptions.defaultToSpeaker,
          ],
        ),
      );

  Future _onEvent(
    AlarmSoundEvent event,
    Emitter<Sound?> emit,
  ) async {
    if (event is PlayAlarmSound) {
      await _playSound(event, emit);
    } else if (event is StopAlarmSound) {
      await _stopSound(emit);
    } else if (event is PlayAlarmSoundAsMedia) {
      await _stopSound(emit);
      await _playSound(event, emit);
    } else if (event is AlarmSoundCompleted) {
      emit(null);
    }
  }

  Future<void> _playSound(
    PlayAlarmSoundEvent event,
    Emitter<Sound?> emit,
  ) async {
    final sound = event.sound;
    final asAlarm = event is! PlayAlarmSoundAsMedia;
    final audioPlayer = this.audioPlayer;
    if (sound == Sound.Default) {
      await FlutterRingtonePlayer.playNotification(asAlarm: asAlarm);
      await _stopSound(emit);
    } else {
      await audioPlayer.play(
        AssetSource('sounds/${sound.fileName()}.mp3'),
        ctx: _getAudioContext(asAlarm),
      );
      emit(sound);
    }
  }

  Future<void> _stopSound(Emitter<Sound?> emit) async {
    await audioPlayer.stop();
    emit(null);
  }

  @override
  Future<void> close() async {
    await onPlayerCompletion.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}

EventTransformer<Event> _throttle<Event>(Duration delay) =>
    (events, mapper) => events.throttleTime(delay).asyncExpand(mapper);
