import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class PlaySoundButton extends StatelessWidget {
  final AbiliaFile sound;
  final ButtonStyle? buttonStyle;

  const PlaySoundButton({
    Key? key,
    required this.sound,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SoundCubit, SoundState, bool>(
        selector: (state) =>
            state is SoundPlaying && state.currentSound == sound,
        builder: (context, isPlaying) => IconActionButton(
          style: buttonStyle ?? actionButtonStyleDark,
          onPressed: () => isPlaying
              ? context.read<SoundCubit>().stopSound()
              : context.read<SoundCubit>().play(sound),
          child: Icon(
            isPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
          ),
        ),
      );
}
