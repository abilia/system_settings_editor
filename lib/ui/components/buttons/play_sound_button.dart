// @dart=2.9

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class PlaySoundButton extends StatelessWidget {
  final Sound sound;
  const PlaySoundButton({
    Key key,
    @required this.sound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoundCubit, SoundState>(
      builder: (context, state) => ActionButton(
        style: actionButtonStyleDark,
        onPressed: sound == Sound.NoSound
            ? null
            : sound == state.currentSound
                ? () async {
                    await context.read<SoundCubit>().stopSound();
                  }
                : () async {
                    await context.read<SoundCubit>().playSound(sound);
                  },
        child: Icon(
          state.currentSound == sound
              ? AbiliaIcons.stop
              : AbiliaIcons.play_sound,
        ),
      ),
    );
  }
}
