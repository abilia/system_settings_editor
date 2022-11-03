import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/notification/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TopLevelListener extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationAlarm? payload;

  const TopLevelListener({
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
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listenWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType ||
                  previous.forcedNewState != current.forcedNewState,
              listener: (context, state) async {
                final navigator = navigatorKey.currentState;
                if (navigator == null) {
                  context.read<AuthenticationBloc>().add(NotReady());
                  return;
                }
                if (state is Authenticated) {
                  await Permission.notification.request();
                  final payload_ = payload;
                  if (payload_ == null) {
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
                      ),
                      (_) => false,
                    );
                  } else {
                    await navigator.pushAndRemoveUntil(
                        GetIt.I<AlarmNavigator>().getFullscreenAlarmRoute(
                          authenticatedState: state,
                          alarm: payload_,
                        ),
                        (_) => false);
                  }
                } else if (state is Unauthenticated) {
                  await navigator.pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (_) {
                        return LoginPage(unauthenticatedState: state);
                      },
                    ),
                    (_) => false,
                  );
                }
              },
            ),
          ],
          child: child,
        ),
      );
}
