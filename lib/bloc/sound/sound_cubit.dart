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
  SoundCubit()
      : audioPlayer = AudioPlayer(),
        audioCache = AudioCache(),
        super(SoundState()) {
    audioCache.fixedPlayer = audioPlayer;
    audioPlayer.onPlayerCompletion.listen((_) {
      emit(SoundState());
    });
  }

  Future<void> play(Object sound) async {
    if (sound is Sound) return playSound(sound);
    if (sound is File) return playFile(sound);
  }

  Future<void> playSound(Sound sound) async {
    if (sound == Sound.Default) {
      await FlutterRingtonePlayer.playNotification();
      emit(SoundState());
    } else {
      await audioCache.play('sounds/${sound.fileName()}.mp3');
      emit(SoundState(currentSound: sound));
    }
  }

  Future<void> playFile(File speech) async {
    await audioCache.playBytes(await speech.readAsBytes());
    emit(SoundState(currentSound: speech));
  }

  Future<void> stopSound() async {
    await audioPlayer.stop();
    emit(SoundState());
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
