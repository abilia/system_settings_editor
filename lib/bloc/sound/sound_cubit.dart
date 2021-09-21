import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:seagull/models/all.dart';

part 'sound_state.dart';

class SoundCubit extends Cubit<SoundState> {
  final AudioPlayer audioPlayer;
  final AudioCache audioCache;

  late final StreamSubscription audioPositionChanged;
  late final StreamSubscription onPlayerCompletion;

  SoundCubit()
      : audioPlayer = AudioPlayer(),
        audioCache = AudioCache(),
        super(NoSoundPlaying()) {
    audioCache.fixedPlayer = audioPlayer;
    onPlayerCompletion = audioPlayer.onPlayerCompletion.listen((_) {
      emit(const NoSoundPlaying());
    });
    audioPositionChanged = audioPlayer.onAudioPositionChanged.listen(
      (position) async {
        final s = state;
        if (s is SoundPlaying) {
          final duration =
              s.duration == 0 ? await audioPlayer.getDuration() : s.duration;
          emit(
            SoundPlaying(
              s.currentSound,
              duration: duration,
              position: position,
            ),
          );
        }
      },
    );
  }

  Future<void> play(Object sound) async {
    if (sound is Sound) return playSound(sound);
    if (sound is File) return playFile(sound);
    if (sound is UnstoredAbiliaFile) return playFile(sound.file);
    throw 'unsupported sound: $sound';
  }

  Future<void> playSound(Sound sound) async {
    if (sound == Sound.Default) {
      emit(SoundPlaying(sound));
      await FlutterRingtonePlayer.playNotification();
      emit(NoSoundPlaying());
    } else {
      await audioCache.play('sounds/${sound.fileName()}.mp3');
      emit(SoundPlaying(sound));
    }
  }

  Future<void> playFile(File speech) async {
    await audioCache.playBytes(await speech.readAsBytes());
    emit(SoundPlaying(speech));
  }

  Future<void> stopSound() async {
    await audioPlayer.stop();
    emit(NoSoundPlaying());
  }

  @override
  Future<void> close() async {
    await super.close();
    await audioPlayer.dispose();
    await audioPositionChanged.cancel();
    await onPlayerCompletion.cancel();
  }
}
