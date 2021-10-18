import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/dialogs/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

class TopLevelListeners extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationAlarm? payload;

  const TopLevelListeners({
    Key? key,
    required this.child,
    required this.navigatorKey,
    this.payload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          BlocListener<ClockBloc, DateTime>(
            listener: (context, state) =>
                GetIt.I<SeagullLogger>().maybeUploadLogs(),
          ),
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listenWhen: (last, current) =>
                GetIt.I<BaseUrlDb>().getBaseUrl() !=
                current.userRepository.baseUrl,
            listener: (context, state) => GetIt.I<BaseUrlDb>().setBaseUrl(
              state.userRepository.baseUrl,
            ),
          ),
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType ||
                previous.forcedNewState != current.forcedNewState,
            listener: (context, state) async {
              final _navigator = navigatorKey.currentState;
              if (_navigator == null) {
                context.read<AuthenticationBloc>().add(NotReady());
                return;
              }
              if (state is Authenticated) {
                await Permission.notification.request();
                final _payload = payload;
                if (_payload == null) {
                  await _navigator.pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (_) {
                        return AuthenticatedBlocsProvider(
                          authenticatedState: state,
                          child: AlarmListeners(
                            child: AuthenticatedListeners(
                              child: CalendarPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    (_) => false,
                  );
                } else {
                  await _navigator.pushAndRemoveUntil(
                      GetIt.I<AlarmNavigator>().getFullscreenAlarmRoute(
                        authenticatedState: state,
                        alarm: _payload,
                      ),
                      (_) => false);
                }
              } else if (state is Unauthenticated) {
                await _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return LoginPage(authState: state);
                    },
                  ),
                  (_) => false,
                );
              }
            },
          ),
        ],
        child: child,
      );
}

class AlarmListeners extends StatelessWidget {
  final Widget child;
  const AlarmListeners({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationCubit, NotificationAlarm?>(
          listener: (context, state) async {
            if (state != null) {
              await GetIt.I<AlarmNavigator>().pushAlarm(context, state);
            }
          },
        ),
        if (!Platform.isAndroid)
          BlocListener<AlarmCubit, NotificationAlarm?>(
            listener: (context, state) async {
              if (state != null) {
                await GetIt.I<AlarmNavigator>().pushAlarm(context, state);
              }
            },
          ),
      ],
      child: child,
    );
  }
}

class AuthenticatedListeners extends StatefulWidget {
  const AuthenticatedListeners({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;
  @override
  _AuthenticatedListenersState createState() => _AuthenticatedListenersState();
}

class _AuthenticatedListenersState extends State<AuthenticatedListeners>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await GetIt.I<SettingsDb>()
        .setAlwaysUse24HourFormat(MediaQuery.of(context).alwaysUse24HourFormat);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await GetIt.I<SettingsDb>().setAlwaysUse24HourFormat(
          MediaQuery.of(context).alwaysUse24HourFormat);
      context
        ..read<ClockBloc>().add(DateTime.now().onlyMinutes())
        ..read<PushBloc>().add(PushEvent('app-resumed'))
        ..read<PermissionBloc>().checkAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActivitiesBloc, ActivitiesState>(
          listenWhen: (_, current) => current is ActivitiesLoaded,
          listener: (context, activitiesState) async {
            final settingsState = context.read<MemoplannerSettingBloc>().state;
            if (settingsState is! MemoplannerSettingsNotLoaded) {
              await scheduleAlarmNotificationsIsolated(
                activitiesState.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
                settingsState.alarmsDisabledUntil,
                settingsState.alarm,
                GetIt.I<FileStorage>(),
              );
            }
          },
        ),
        BlocListener<MemoplannerSettingBloc, MemoplannerSettingsState>(
          listenWhen: (previous, current) =>
              (previous is MemoplannerSettingsNotLoaded &&
                  current is! MemoplannerSettingsNotLoaded) ||
              previous.alarm != current.alarm,
          listener: (context, state) async {
            final activitiesState = context.read<ActivitiesBloc>().state;
            if (activitiesState is ActivitiesLoaded) {
              await scheduleAlarmNotificationsIsolated(
                activitiesState.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
                state.alarmsDisabledUntil,
                state.alarm,
                GetIt.I<FileStorage>(),
              );
            }
          },
        ),
        BlocListener<LicenseBloc, LicenseState>(
          listener: (context, state) async {
            if (state is NoValidLicense) {
              BlocProvider.of<AuthenticationBloc>(context).add(
                LoggedOut(
                  loggedOutReason: LoggedOutReason.LICENSE_EXPIRED,
                ),
              );
            }
          },
        ),
        BlocListener<PermissionBloc, PermissionState>(
          listenWhen: _notificationsDenied,
          listener: (context, state) => showViewDialog(
            context: context,
            builder: (context) => const NotificationPermissionWarningDialog(),
          ),
        ),
        if (Config.isMP)
          BlocListener<InactivityCubit, InactivityState>(
            listenWhen: (previous, current) =>
                current is InactivityThresholdReachedState &&
                previous is ActivityDetectedState,
            listener: (context, state) {
              context.read<MonthCalendarBloc>().add(GoToCurrentMonth());
              context.read<WeekCalendarBloc>().add(GoToCurrentWeek());
              context.read<DayPickerBloc>().add(CurrentDay());
            },
          ),
        if (!Platform.isIOS) fullscreenAlarmPremissionListener(context),
      ],
      child: widget.child,
    );
  }

  BlocListener<PermissionBloc, PermissionState>
      fullscreenAlarmPremissionListener(BuildContext context) {
    return BlocListener<PermissionBloc, PermissionState>(
      listenWhen: (previous, current) {
        if (!previous.status.containsKey(Permission.systemAlertWindow) &&
            current.status.containsKey(Permission.systemAlertWindow) &&
            !(current.status[Permission.systemAlertWindow]?.isGranted ??
                false)) {
          final authState = context.read<AuthenticationBloc>().state;
          if (authState is Authenticated) {
            return authState.newlyLoggedIn;
          }
        }
        return false;
      },
      listener: (context, state) => showViewDialog(
        context: context,
        builder: (context) => FullscreenAlarmInfoDialog(
          showRedirect: true,
        ),
      ),
    );
  }

  bool _notificationsDenied(
          PermissionState previous, PermissionState current) =>
      (current.status[Permission.notification]?.isDeniedOrPermenantlyDenied ??
          false) &&
      !(previous.status[Permission.notification]?.isDeniedOrPermenantlyDenied ??
          false);
}
