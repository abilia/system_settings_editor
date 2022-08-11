import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';

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

            if (!context.read<MemoplannerSettingBloc>().state.useScreensaver) {
              return;
            }
            final authProviders = copiedAuthProviders(context);
            final screenSaverRoute = MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: authProviders,
                child: const ScreenSaverPage(),
              ),
              settings: const RouteSettings(name: 'ScreenSaverPage'),
            );
            GetIt.I<AlarmNavigator>().addScreenSaver(screenSaverRoute);
            Navigator.of(context).push(screenSaverRoute);
          },
        );
}
