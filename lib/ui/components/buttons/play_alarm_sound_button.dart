import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class PlayAlarmSoundButton extends StatelessWidget {
  final Sound sound;
  const PlayAlarmSoundButton({
    Key? key,
    required this.sound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmSoundCubit, Sound?>(
      builder: (context, state) => ActionButton(
        style: actionButtonStyleDark,
        onPressed: sound == Sound.NoSound
            ? null
            : state == sound
                ? () async {
                    await context.read<AlarmSoundCubit>().stopSound();
                  }
                : () async {
                    await context.read<AlarmSoundCubit>().playSound(sound);
                  },
        child: Icon(
          state == sound ? AbiliaIcons.stop : AbiliaIcons.playSound,
        ),
      ),
    );
  }
}
