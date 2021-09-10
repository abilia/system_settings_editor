import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/sound/sound_cubit.dart';
import 'package:seagull/models/sound.dart';
import 'package:seagull/ui/all.dart';

class GreenPlaySoundButton extends StatelessWidget {
  final Object? sound;

  const GreenPlaySoundButton({
    Key? key,
    required this.sound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sound = this.sound;
    final translate = Translator.of(context).translate;
    var hasSound = sound != null;
    return BlocBuilder<SoundCubit, SoundState>(
      builder: (context, state) => IconAndTextButton(
        text: hasSound && state.currentSound == sound
            ? translate.stop
            : translate.play,
        icon: hasSound && state.currentSound == sound
            ? AbiliaIcons.stop
            : AbiliaIcons.play_sound,
        onPressed: sound == Sound.NoSound || sound == null
            ? null
            : sound == state.currentSound
                ? () {
                    context.read<SoundCubit>().stopSound();
                  }
                : () {
                    context.read<SoundCubit>().play(sound);
                  },
        style: hasSound && state.currentSound == sound
            ? iconTextButtonStyleRed
            : iconTextButtonStyleGreen,
      ),
    );
  }
}
