import 'package:auth/auth.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/notification/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TopLevelListeners extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationAlarm? payload;

  const TopLevelListeners({
    required this.child,
    required this.navigatorKey,
    Key? key,
    this.payload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: context.read<TouchDetectionCubit>().onPointerDown,
        child: MultiBlocListener(
          listeners: [
            BlocListener<ClockBloc, DateTime>(
              listener: (context, state) =>
                  GetIt.I<SeagullLogger>().maybeUploadLogs(),
            ),
            AuthenticationListener(
              navigatorKey: navigatorKey,
              onAuthenticated: (navigator, state) async {
                await Permission.notification.request();
                final alarm = payload;
                if (alarm == null) {
                  await navigator.pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => AuthenticatedBlocsProvider(
                        authenticatedState: state,
                        child: AlarmListener(
                          child: AuthenticatedListener(
                            newlyLoggedIn: state.newlyLoggedIn,
                            child: const CalendarPage(),
                          ),
                        ),
                      ),
                      settings: (CalendarPage).routeSetting(),
                    ),
                    (_) => false,
                  );
                } else {
                  await navigator.pushAndRemoveUntil(
                      GetIt.I<AlarmNavigator>().getFullscreenAlarmRoute(
                        authenticatedState: state,
                        alarm: alarm,
                      ),
                      (_) => false);
                }
              },
              onUnauthenticated: (context, navigator, state) async {
                context.read<SpeechSettingsCubit>().reload();
                await navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => LoginPage(unauthenticatedState: state),
                    settings: (LoginPage).routeSetting(
                      properties: {
                        'logout reason': state.loggedOutReason.name,
                      },
                    ),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
          child: child,
        ),
      );
}
