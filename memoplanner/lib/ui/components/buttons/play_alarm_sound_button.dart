import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/bloc/all.dart';

class PlayAlarmSoundButton extends StatelessWidget {
  final Sound sound;
  const PlayAlarmSoundButton({
    required this.sound,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmSoundBloc, Sound?>(
      builder: (context, state) => IconActionButton(
        style: actionButtonStyleDark,
        onPressed: () {
          if (sound != Sound.NoSound) {
            if (state == sound) {
              return context.read<AlarmSoundBloc>().add(const StopSoundAlarm());
            }
            return context.read<AlarmSoundBloc>().add(PlaySoundAlarm(sound));
          }
        },
        child: Icon(
          state == sound ? AbiliaIcons.stop : AbiliaIcons.playSound,
        ),
      ),
    );
  }
}