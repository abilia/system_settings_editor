import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

class AuthenticatedListener extends StatefulWidget {
  const AuthenticatedListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _AuthenticatedListenerState createState() => _AuthenticatedListenerState();
}

class _AuthenticatedListenerState extends State<AuthenticatedListener>
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
        ..read<ClockBloc>().setTime()
        ..read<PushBloc>().add(const PushEvent('app-resumed'))
        ..read<PermissionBloc>().checkAll();
      if (Config.isMP) {
        context
            .read<WakeLockCubit>()
            .setScreenTimeout(await SystemSettingsEditor.screenOffTimeout);
      }
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
                const LoggedOut(
                  loggedOutReason: LoggedOutReason.licenseExpired,
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
        if (Config.isMP) ...[
          BlocListener<InactivityCubit, InactivityState>(
            listenWhen: (previous, current) =>
                current is InactivityThresholdReachedState &&
                previous is ActivityDetectedState,
            listener: (context, state) {
              context.read<MonthCalendarCubit>().goToCurrentMonth();
              context.read<WeekCalendarCubit>().goToCurrentWeek();
              context.read<DayPickerBloc>().add(CurrentDay());
            },
          ),
          KeepScreenAwakeListener(),
        ],
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
        builder: (context) => const FullscreenAlarmInfoDialog(
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
