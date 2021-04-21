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
                        child: AuthenticatedListeners(
                          key: authedStateKey,
                          alarm: payload,
                          child: payload != null
                              ? FullScreenAlarm(alarm: payload)
                              : CalendarPage(),
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

class AuthenticatedListeners extends StatefulWidget {
  const AuthenticatedListeners({
    Key key,
    @required this.child,
    this.alarm,
  }) : super(key: key);

  final Widget child;
  final NotificationAlarm alarm;
  BlocListenerCondition<AlarmStateBase> get listenWhen => alarm != null
      ? (_, current) => current is AlarmState && current.alarm != alarm
      : null;
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
          listener: (context, state) async {
            if (state is ActivitiesLoaded) {
              final settingsState =
                  context.read<MemoplannerSettingBloc>().state;
              await GetIt.I<AlarmScheduler>()(
                state.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
                settingsState.settings,
                GetIt.I<FileStorage>(),
              );
            }
          },
        ),
        BlocListener<LicenseBloc, LicenseState>(
          listener: (context, state) async {
            if (state is NoValidLicense) {
              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut(
                loggedOutReason: LoggedOutReason.LICENSE_EXPIRED,
              ));
            }
          },
        ),
        BlocListener<AlarmBloc, AlarmStateBase>(
          listener: _alarmListener,
          listenWhen: widget.listenWhen,
        ),
        BlocListener<NotificationBloc, AlarmStateBase>(
          listener: _alarmListener,
          listenWhen: widget.listenWhen,
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

  void _alarmListener(BuildContext context, AlarmStateBase state) async {
    if (state is AlarmState) {
      await GetIt.I<AlarmNavigator>().pushAlarm(context, state.alarm);
    }
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
