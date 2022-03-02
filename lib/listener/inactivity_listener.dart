import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/models/settings/memoplanner_settings_enums.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/copied_auth_providers.dart';

class CalendarInactivityListener
    extends BlocListener<InactivityCubit, InactivityState> {
  CalendarInactivityListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              current is CalendarInactivityThresholdReachedState &&
              previous is ActivityDetectedState,
          listener: (context, state) {
            context.read<MonthCalendarCubit>().goToCurrentMonth();
            context.read<WeekCalendarCubit>().goToCurrentWeek();
            context.read<DayPickerBloc>().add(CurrentDay());
          },
        );
}

class HomeScreenInactivityListener
    extends BlocListener<InactivityCubit, InactivityState> {
  HomeScreenInactivityListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              current is HomeScreenInactivityThresholdReachedState &&
              previous is ActivityDetectedState,
          listener: (context, state) async {
            final authProviders = copiedAuthProviders(context);

            if ((state as HomeScreenInactivityThresholdReachedState)
                .showScreenSaver) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: authProviders,
                    child: const ScreenSaverPage(),
                  ),
                ),
              );
            }
            int initialIndex = 0;

            switch (state.startView) {
              case StartView.photoAlbum:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: const PhotoCalendarPage(),
                    ),
                  ),
                );
                return;
              case StartView.dayCalendar:
                context.read<DayPickerBloc>().add(CurrentDay());
                break;
              case StartView.monthCalendar:
                context.read<MonthCalendarCubit>().goToCurrentMonth();
                initialIndex = 2;
                break;
              case StartView.weekCalendar:
                context.read<WeekCalendarCubit>().goToCurrentWeek();
                initialIndex = 1;
                break;
              case StartView.menu:
                initialIndex = 3;
                break;
            }

            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => MultiBlocProvider(
                  providers: authProviders,
                  child: AuthenticatedListener(
                    child: AlarmListener(
                      child: CalendarPage(
                        initialIndex: initialIndex,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
