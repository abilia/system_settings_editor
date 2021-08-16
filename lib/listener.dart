// @dart=2.9

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/dialogs/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

final GlobalKey authedStateKey = GlobalKey(debugLabel: 'authedStateKey');
BuildContext get authContext => authedStateKey.currentContext;

class TopLevelListeners extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationAlarm payload;

  NavigatorState get _navigator => navigatorKey.currentState;
  const TopLevelListeners({
    Key key,
    this.child,
    @required this.navigatorKey,
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
              if (_navigator == null) {
                context.read<AuthenticationBloc>().add(NotReady());
                return;
              }
              if (state is Authenticated) {
                await Permission.notification.request();
                await _navigator.pushAndRemoveUntil<void>(
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return AuthenticatedBlocsProvider(
                        authenticatedState: state,
                        child: AlarmListeners(
                          alarm: payload,
                          child: payload != null
                              ? FullScreenAlarm(alarm: payload)
                              : AuthenticatedListeners(
                                  key: authedStateKey,
                                  child: CalendarPage(),
                                ),
                        ),
                      );
                    },
                  ),
                  (_) => false,
                );
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

class AlarmListeners extends StatefulWidget {
  static final _log = Logger((AlarmListeners).toString());
  final Widget child;
  final NotificationAlarm alarm;
  const AlarmListeners({Key key, this.child, this.alarm}) : super(key: key);

  @override
  _AlarmListenersState createState() => _AlarmListenersState();
}

class _AlarmListenersState extends State<AlarmListeners>
    with WidgetsBindingObserver {
  bool get alarmScreen => widget.alarm != null;
  AppLifecycleState appLifecycleState;

  BlocListenerCondition<AlarmStateBase> get listenWhen => alarmScreen
      ? (_, current) => current is AlarmState && current.alarm != widget.alarm
      : (_, __) =>
          appLifecycleState == null ||
          appLifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    appLifecycleState = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AlarmListeners._log.info('$state');
    appLifecycleState = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationBloc, AlarmStateBase>(
          listener: _alarmListener,
          listenWhen: listenWhen,
        ),
        BlocListener<AlarmBloc, AlarmStateBase>(
          listener: _alarmListener,
          listenWhen: listenWhen,
        ),
      ],
      child: widget.child,
    );
  }

  void _alarmListener(BuildContext context, AlarmStateBase state) async {
    if (state is AlarmState) {
      await GetIt.I<AlarmNavigator>().pushAlarm(context, state.alarm);
    }
  }
}

class AuthenticatedListeners extends StatefulWidget {
  const AuthenticatedListeners({
    Key key,
    @required this.child,
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await GetIt.I<SettingsDb>()
        .setAlwaysUse24HourFormat(MediaQuery.of(context).alwaysUse24HourFormat);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
              await GetIt.I<AlarmScheduler>()(
                activitiesState.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
                settingsState.settings,
                GetIt.I<FileStorage>(),
              );
            }
          },
        ),
        BlocListener<MemoplannerSettingBloc, MemoplannerSettingsState>(
          listenWhen: (previous, current) =>
              (previous is MemoplannerSettingsNotLoaded &&
                  current is! MemoplannerSettingsNotLoaded) ||
              AlarmSettingsState.fromMemoplannerSettings(previous) !=
                  AlarmSettingsState.fromMemoplannerSettings(current),
          listener: (context, state) async {
            final activitiesState = context.read<ActivitiesBloc>().state;
            if (activitiesState is ActivitiesLoaded) {
              await GetIt.I<AlarmScheduler>()(
                activitiesState.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
                state.settings,
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
            !current.status[Permission.systemAlertWindow].isGranted) {
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
      current.status[Permission.notification].isDeniedOrPermenantlyDenied &&
      !previous.status[Permission.notification].isDeniedOrPermenantlyDenied;
}
