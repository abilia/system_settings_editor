import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:seagull/models/all.dart';

class AlarmSoundCubit extends Cubit<Sound?> {
  final AudioPlayer audioPlayer;
  final AudioCache audioCache;
  late final StreamSubscription onPlayerCompletion;

  AlarmSoundCubit()
      : audioPlayer = AudioPlayer(),
        audioCache = AudioCache(),
        super(null) {
    audioCache.fixedPlayer = audioPlayer;
    onPlayerCompletion =
        audioPlayer.onPlayerCompletion.listen((_) => emit(null));
  }

  Future<void> playSound(Sound sound) async {
    if (sound == Sound.Default) {
      await FlutterRingtonePlayer.playNotification();
      emit(null);
    } else {
      await audioCache.play('sounds/${sound.fileName()}.mp3');
      emit(sound);
    }
  }

  Future<void> stopSound() async {
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
