import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ReturnToHomeScreenListener extends StatelessWidget {
  final Widget child;

  const ReturnToHomeScreenListener({
    required this.child,
    super.key,
  });
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
              DefaultTabController.maybeOf(context)?.index = startViewIndex,
        ),
        BlocListener<ActionIntentCubit, String>(
          listenWhen: (_, current) => current == AndroidIntentAction.homeButton,
          listener: (context, state) async {
            Navigator.of(context).popUntilRootOrPersistentPage();
            DefaultTabController.of(context).index = startViewIndex;
            await cancelAllActiveNotifications();
          },
        ),
      ],
      child: child,
    );
  }
}
