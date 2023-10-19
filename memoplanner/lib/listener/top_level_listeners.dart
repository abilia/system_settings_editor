import 'dart:async';

import 'package:auth/auth.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/notification/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_logging/logging.dart';

class TopLevelListeners extends StatefulWidget {
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
  State<TopLevelListeners> createState() => _TopLevelListenersState();
}

class _TopLevelListenersState extends State<TopLevelListeners>
    with WidgetsBindingObserver {
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await context.read<ClockCubit>().setTime(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: context.read<TouchDetectionCubit>().onPointerDown,
        child: MultiBlocListener(
          listeners: [
            BlocListener<ClockCubit, DateTime>(
              listenWhen: (previous, current) =>
                  previous.minute != 0 && current.minute == 0,
              listener: (context, state) async =>
                  GetIt.I<SeagullLogger>().maybeUploadLogs(),
            ),
            AuthenticationListener(
              navigatorKey: widget.navigatorKey,
              onAuthenticated: (context, navigator, state) async {
                await Permission.notification.request();
                final alarm = widget.payload;
                if (alarm == null) {
                  await navigator.pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => AuthenticatedBlocsProvider(
                        authenticatedState: state,
                        child: const AlarmListener(
                          child: AuthenticatedListener(
                            child: CalendarPage(),
                          ),
                        ),
                      ),
                      settings: (CalendarPage).routeSetting(),
                    ),
                    (_) => false,
                  );
                } else {
                  unawaited(
                    navigator.pushAndRemoveUntil<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => AuthenticatedBlocsProvider(
                          authenticatedState: state,
                          child: const AlarmListener(
                            child: AlarmBackgroundPage(),
                          ),
                        ),
                        settings: (AlarmBackgroundPage).routeSetting(),
                      ),
                      (_) => false,
                    ),
                  );
                  await navigator.push(
                    GetIt.I<AlarmNavigator>().getFullscreenAlarmRoute(
                      authenticatedState: state,
                      alarm: alarm,
                    ),
                  );
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
          child: widget.child,
        ),
      );
}
