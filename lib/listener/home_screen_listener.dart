import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ReturnToHomeScreenListener extends StatelessWidget {
  final Widget child;

  const ReturnToHomeScreenListener({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!Config.isMP) return child;

    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) => MultiBlocListener(
        listeners: [
          BlocListener<InactivityCubit, InactivityState>(
            listenWhen: (previous, current) =>
                current is HomeScreenInactivityThresholdReached &&
                previous is! HomeScreenInactivityThresholdReached &&
                current.startView != StartView.photoAlbum,
            listener: (context, state) {
              if (state is! HomeScreenInactivityThresholdReached) return;
              DefaultTabController.of(context)?.index =
                  settingsState.startViewIndex(state.startView);
            },
          ),
          BlocListener<ActionIntentCubit, String>(
            listenWhen: (_, current) =>
                current == AndroidIntentAction.homeButton,
            listener: (context, state) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              DefaultTabController.of(context)?.index =
                  settingsState.startViewIndex(settingsState.startView);
              GetIt.I<AlarmNavigator>().clearAlarmStack();
              cancelAllActiveNotifications();
            },
          ),
        ],
        child: child,
      ),
    );
  }
}
