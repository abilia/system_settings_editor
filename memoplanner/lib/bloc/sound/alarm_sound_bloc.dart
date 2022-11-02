import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/sound/sound_bloc.dart';

import 'package:seagull/models/all.dart';

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
        .listen((_) => add(const SoundAlarmCompleted()));
    audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          defaultToSpeaker: true,
          category: AVAudioSessionCategory.multiRoute,
          options: [],
        ),
      ),
    );
  }

  Future _onEvent(
    AlarmSoundEvent event,
    Emitter<Sound?> emit,
  ) async {
    if (event is PlaySoundAlarm) {
      await _playSound(event.sound, emit);
    } else if (event is StopSoundAlarm) {
      await _stopSound(emit);
    } else if (event is RestartSoundAlarm) {
      await _stopSound(emit);
      await _playSound(event.sound, emit);
    } else if (event is SoundAlarmCompleted) {
      emit(null);
    }
  }

  Future<void> _playSound(Sound sound, Emitter<Sound?> emit) async {
    if (sound == Sound.Default) {
      await FlutterRingtonePlayer.playNotification(asAlarm: true);
      await _stopSound(emit);
    } else {
      await audioPlayer.play(AssetSource('sounds/${sound.fileName()}.mp3'));
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
