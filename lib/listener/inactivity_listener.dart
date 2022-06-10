import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarInactivityListener
    extends BlocListener<InactivityCubit, InactivityState> {
  CalendarInactivityListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              previous is SomethingHappened && current is! SomethingHappened,
          listener: (context, state) {
            context.read<MonthCalendarCubit>().goToCurrentMonth();
            context.read<WeekCalendarCubit>().goToCurrentWeek();
            context.read<DayPickerBloc>().add(const CurrentDay());
          },
        );
}

class HomeScreenInactivityListener extends StatelessWidget {
  final Widget child;
  final MemoplannerSettingsState settingsState;

  const HomeScreenInactivityListener({
    Key? key,
    required this.settingsState,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!Config.isMP) return child;

    return BlocListener<InactivityCubit, InactivityState>(
      listenWhen: (previous, current) =>
          current is HomeScreenInactivityThresholdReached &&
          previous is! HomeScreenInactivityThresholdReached &&
          current.startView != StartView.photoAlbum,
      listener: (context, state) {
        if (state is! HomeScreenInactivityThresholdReached) return;
        DefaultTabController.of(context)?.index =
            settingsState.startViewIndex(state.startView);
      },
      child: child,
    );
  }
}

class ScreenSaverListener
    extends BlocListener<InactivityCubit, InactivityState> {
  ScreenSaverListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              current is HomeScreenInactivityThresholdReached &&
              previous is! HomeScreenInactivityThresholdReached,
          listener: (context, state) {
            Navigator.of(context)
                .popUntil((route) => route.isFirst || route is AlarmRoute);
            if (state is! HomeScreenInactivityThresholdReached ||
                !state.screensaverOrPhotoAlbum) return;

            final authProviders = copiedAuthProviders(context);
            if (state.startView == StartView.photoAlbum) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const PhotoCalendarPage(),
                  ),
                  settings: const RouteSettings(name: 'PhotoCalendarPage'),
                ),
              );
            }

            if (state.showScreensaver) {
              final screenSaverRoute = MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: authProviders,
                  child: const ScreenSaverPage(),
                ),
                settings: const RouteSettings(name: 'ScreenSaverPage'),
              );
              GetIt.I<AlarmNavigator>().addScreenSaver(screenSaverRoute);
              Navigator.of(context).push(screenSaverRoute);
            }
          },
        );
}
