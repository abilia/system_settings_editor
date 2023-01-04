import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/bloc/all.dart';

class PlaySoundButton extends StatelessWidget {
  final AbiliaFile sound;
  final ButtonStyle? buttonStyle;

  const PlaySoundButton({
    required this.sound,
    this.buttonStyle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocListener<NavigationCubit, NavigationState>(
        listener: (context, state) {
          if (state is Push) {
            context.read<SoundBloc>().add(const StopSound());
          }
        },
        child: BlocSelector<SoundBloc, SoundState, bool>(
          selector: (state) =>
              state is SoundPlaying && state.currentSound == sound,
          builder: (context, isPlaying) => IconActionButton(
            style: buttonStyle ?? actionButtonStyleDark,
            onPressed: () => isPlaying
                ? context.read<SoundBloc>().add(const StopSound())
                : context.read<SoundBloc>().add(PlaySound(sound)),
            child: Icon(
              isPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
            ),
          ),
        ),
      );
}
