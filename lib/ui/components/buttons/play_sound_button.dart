import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class PlaySoundButton extends StatelessWidget {
  final Object? sound;
  final ButtonStyle? buttonStyle;

  const PlaySoundButton({
    Key? key,
    required this.sound,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sound = this.sound;
    return BlocBuilder<SoundCubit, SoundState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) => ActionButton(
        style: buttonStyle ?? actionButtonStyleDark,
        onPressed: sound == Sound.NoSound || sound == null
            ? null
            : state is SoundPlaying && sound == state.currentSound
                ? () async {
                    await context.read<SoundCubit>().stopSound();
                  }
                : () async {
                    await context.read<SoundCubit>().play(sound);
                  },
        child: Icon(
          sound != null && state is SoundPlaying && state.currentSound == sound
              ? AbiliaIcons.stop
              : AbiliaIcons.play_sound,
        ),
      ),
    );
  }
}
