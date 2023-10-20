import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class CalendarInactivityListener
    extends BlocListener<InactivityCubit, InactivityState> {
  CalendarInactivityListener({super.child, super.key})
      : super(
          listenWhen: (previous, current) =>
              previous is! ReturnToTodayState && current is ReturnToTodayState,
          listener: (context, state) {
            context.read<MonthCalendarCubit>().goToCurrentMonth();
            context.read<WeekCalendarCubit>().goToCurrentWeek();
            context.read<DayPickerBloc>().add(const CurrentDay());
          },
        );
}

class ScreensaverListener
    extends BlocListener<InactivityCubit, InactivityState> {
  ScreensaverListener({super.key})
      : super(
          listenWhen: (previous, current) => current is HomeScreenState,
          listener: (context, state) {
            // Need to pop to root here and not in [ReturnToHomeScreenListener]
            // since otherwise we might push the screensaver page before we pop
            // to root
            Navigator.of(context).popUntilRootOrPersistentPage();
            if (state is! ScreensaverState) return;
            final authProviders = copiedAuthProviders(context);
            final screensaverRoute = MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: authProviders,
                child: const ScreensaverPage(),
              ),
              settings: (ScreensaverPage).routeSetting(),
            );
            GetIt.I<AlarmNavigator>().addScreensaver(screensaverRoute);
            Navigator.of(context).push(screensaverRoute);
          },
        );
}

class PopScreensaverListener
    extends BlocListener<InactivityCubit, InactivityState> {
  PopScreensaverListener({super.key})
      : super(
          listenWhen: (previous, current) => current is SomethingHappened,
          listener: (context, state) =>
              GetIt.I<AlarmNavigator>().popScreensaverRoute(),
        );
}
