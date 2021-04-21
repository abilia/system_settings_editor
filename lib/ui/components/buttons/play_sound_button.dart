import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class PlaySoundButton extends StatelessWidget {
  final Sound sound;
  const PlaySoundButton({
    Key key,
    @required this.sound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      style: actionButtonStyleDark,
      onPressed: sound == Sound.NoSound
          ? null
          : () async {
              if (sound == Sound.Default) {
                await FlutterRingtonePlayer.playNotification();
              } else {
                final audioCache = AudioCache();
                audioCache.respectSilence = true;
                await audioCache.play('sounds/${sound.fileName()}.mp3');
              }
            },
      child: Icon(
        AbiliaIcons.play_sound,
      ),
    );
  }
}
