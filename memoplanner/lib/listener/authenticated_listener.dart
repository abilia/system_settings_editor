import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class AuthenticatedListener extends StatefulWidget {
  final bool newlyLoggedIn;

  const AuthenticatedListener({
    required this.child,
    required this.newlyLoggedIn,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  State createState() => _AuthenticatedListenerState();
}

class _AuthenticatedListenerState extends State<AuthenticatedListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await GetIt.I<SettingsDb>()
        .setAlwaysUse24HourFormat(MediaQuery.of(context).alwaysUse24HourFormat);
    await _readScreenTimeOut();
    await _fetchDeviceLicense();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.wait([
        GetIt.I<SettingsDb>().setAlwaysUse24HourFormat(
            MediaQuery.of(context).alwaysUse24HourFormat),
        context.read<ClockBloc>().setTime(DateTime.now()),
        context.read<PermissionCubit>().checkAll(),
        _readScreenTimeOut(),
        _fetchDeviceLicense(),
      ]);
    }
  }

  Future<void> _readScreenTimeOut() async {
    if (Config.isMP) {
      context
          .read<WakeLockCubit>()
          .setScreenTimeout(await SystemSettingsEditor.screenOffTimeout);
    }
  }

  Future<void> _fetchDeviceLicense() async {
    if (Config.isMP) {
      await context.read<DeviceRepository>().fetchDeviceLicense();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActivitiesCubit, ActivitiesChanged>(
          listener: (context, state) =>
              context.read<NotificationBloc>().add(ScheduleNotifications()),
        ),
        BlocListener<MemoplannerSettingsBloc, MemoplannerSettings>(
          listenWhen: (previous, current) =>
              (previous is MemoplannerSettingsNotLoaded &&
                  current is! MemoplannerSettingsNotLoaded) ||
              previous.alarm != current.alarm,
          listener: (context, state) =>
              context.read<NotificationBloc>().add(ScheduleNotifications()),
        ),
        BlocListener<TimerCubit, TimerState>(
          listener: (context, state) =>
              context.read<NotificationBloc>().add(ScheduleNotifications()),
        ),
        BlocListener<LicenseCubit, LicenseState>(
          listener: (context, state) async {
            if (Config.isMP && state is NoValidLicense) {
              await showViewDialog(
                context: context,
                builder: (context) => const LicenseExpiredWarningDialog(),
                routeSettings: (LicenseExpiredWarningDialog).routeSetting(),
              );
            } else if (state is! ValidLicense) {
              BlocProvider.of<AuthenticationBloc>(context).add(
                const LoggedOut(
                  loggedOutReason: LoggedOutReason.noLicense,
                ),
              );
            }
          },
        ),
        BlocListener<PermissionCubit, PermissionState>(
          listenWhen: _notificationsDenied,
          listener: (context, state) async => showViewDialog(
            context: context,
            builder: (context) => const NotificationPermissionWarningDialog(),
            routeSettings: (NotificationPermissionWarningDialog).routeSetting(),
          ),
        ),
        AuthenticatedDialogListener(
          authenticatedDialogCubit: context.read<AuthenticatedDialogCubit>(),
        ),
        if (Config.isMP) ...[
          CalendarInactivityListener(),
          ScreensaverListener(),
          PopScreensaverListener(),
          KeepScreenAwakeListener(),
        ],
      ],
      child: widget.child,
    );
  }

  bool _notificationsDenied(
          PermissionState previous, PermissionState current) =>
      (current.status[Permission.notification]?.isDeniedOrPermanentlyDenied ??
          false) &&
      !(previous.status[Permission.notification]?.isDeniedOrPermanentlyDenied ??
          false);
}

class LicenseExpiredWarningDialog extends StatelessWidget {
  const LicenseExpiredWarningDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WarningDialog(
      text: Lt.of(context).licenseExpiredMessage,
    );
  }
}
