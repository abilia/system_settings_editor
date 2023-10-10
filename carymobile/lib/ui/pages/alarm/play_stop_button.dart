part of 'alarm_page.dart';

class PlayStopButton extends StatelessWidget {
  const PlayStopButton({super.key});

  @override
  Widget build(BuildContext context) {
    switch (context.watch<AlarmPageBloc>().state) {
      case (AlarmPlaying()):
        return ActionButtonBlack(
          onPressed: () => context.read<AlarmPageBloc>().add(StopAlarm()),
          leading: const Icon(AbiliaIcons.stop),
          text: 'Stop',
        );
      default:
        return ActionButtonBlack(
          onPressed: () => context.read<AlarmPageBloc>().add(PlayAfter()),
          leading: const Icon(AbiliaIcons.playSound),
          text: 'Play',
        );
    }
  }
}
