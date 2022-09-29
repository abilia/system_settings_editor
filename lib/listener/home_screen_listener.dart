import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ReturnToHomeScreenListener extends StatelessWidget {
  final Widget child;

  const ReturnToHomeScreenListener({
    required this.child,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!Config.isMP) return child;

    final startViewIndex = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.functions.startViewIndex);

    return MultiBlocListener(
      listeners: [
        BlocListener<InactivityCubit, InactivityState>(
          listenWhen: (previous, current) =>
              previous is! HomeScreenState && current is HomeScreenState,
          listener: (context, state) =>
              DefaultTabController.of(context)?.index = startViewIndex,
        ),
        BlocListener<ActionIntentCubit, String>(
          listenWhen: (_, current) => current == AndroidIntentAction.homeButton,
          listener: (context, state) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            DefaultTabController.of(context)?.index = startViewIndex;
            GetIt.I<AlarmNavigator>().clearAlarmStack();
            cancelAllActiveNotifications();
          },
        ),
      ],
      child: child,
    );
  }
}
