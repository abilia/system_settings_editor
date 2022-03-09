import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/memoplanner_settings_enums.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/copied_auth_providers.dart';

class CalendarInactivityListener
    extends BlocListener<InactivityCubit, InactivityState> {
  CalendarInactivityListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              current is CalendarInactivityThresholdReached &&
              previous is ActivityDetected,
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
              current is HomeScreenInactivityThresholdReached &&
              previous is ActivityDetected,
          listener: (context, state) async {
            final authProviders = copiedAuthProviders(context);

            if ((state as HomeScreenInactivityThresholdReached)
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
                break;
              case StartView.weekCalendar:
                context.read<WeekCalendarCubit>().goToCurrentWeek();
                break;
              default:
            }
            context.read<CalendarViewCubit>().setCalendarTab(state.startView);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
}
