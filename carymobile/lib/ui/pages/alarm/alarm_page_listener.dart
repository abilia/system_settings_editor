part of 'alarm_page.dart';

class AlarmPageListeners extends StatelessWidget {
  final Widget child;

  const AlarmPageListeners({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) => context.read<AlarmPageBloc>().add(CancelAlarm()),
      child: BlocListener<AlarmPageBloc, AlarmPageState>(
        listenWhen: (previous, current) => current is AlarmPageClosed,
        listener: (BuildContext context, AlarmPageState state) =>
            Navigator.of(context).maybePop,
        child: child,
      ),
    );
  }
}
