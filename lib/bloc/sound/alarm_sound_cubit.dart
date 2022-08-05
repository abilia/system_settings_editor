import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:seagull/models/all.dart';

class AlarmSoundCubit extends Cubit<Sound?> {
  final AudioPlayer audioPlayer;
  late final StreamSubscription onPlayerCompletion;

  AlarmSoundCubit()
      : audioPlayer = AudioPlayer(),
        super(null) {
    onPlayerCompletion = audioPlayer.onPlayerComplete.listen((_) => emit(null));
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

  Future<void> playSound(Sound sound) async {
    if (sound == Sound.Default) {
      await FlutterRingtonePlayer.playNotification(asAlarm: true);
      emit(null);
    } else {
      await audioPlayer.play(
        AssetSource('sounds/${sound.fileName()}.mp3'),
      );
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
