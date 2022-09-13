import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/utils/all.dart';

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
      GetIt.I<SettingsDb>().setAlwaysUse24HourFormat(
          MediaQuery.of(context).alwaysUse24HourFormat);
      context
        ..read<ClockBloc>().setTime(DateTime.now())
        ..read<SyncBloc>().add(const SyncAll())
        ..read<PermissionCubit>().checkAll();
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
          listener: (context, state) =>
              context.read<NotificationBloc>().add(NotificationEvent()),
        ),
        BlocListener<MemoplannerSettingBloc, MemoplannerSettingsState>(
          listenWhen: (previous, current) =>
              (previous is MemoplannerSettingsNotLoaded &&
                  current is! MemoplannerSettingsNotLoaded) ||
              previous.alarm != current.alarm,
          listener: (context, state) =>
              context.read<NotificationBloc>().add(NotificationEvent()),
        ),
        BlocListener<TimerCubit, TimerState>(
          listener: (context, state) =>
              context.read<NotificationBloc>().add(NotificationEvent()),
        ),
        BlocListener<LicenseCubit, LicenseState>(
          listener: (context, state) async {
            if (Config.isMP && state is NoValidLicense) {
              showViewDialog(
                context: context,
                builder: (context) => WarningDialog(
                  text: Translator.of(context).translate.licenseExpiredMessage,
                ),
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
          listener: (context, state) => showViewDialog(
            context: context,
            builder: (context) => const NotificationPermissionWarningDialog(),
          ),
        ),
        if (widget.newlyLoggedIn) StarterSetListener(),
        if (Config.isMP) ...[
          CalendarInactivityListener(),
          ScreensaverListener(),
          PopScreensaverListener(),
          KeepScreenAwakeListener(),
        ] else if (!Platform.isIOS && widget.newlyLoggedIn)
          FullscreenAlarmPremissionListener(),
      ],
      child: widget.child,
    );
  }

  bool _notificationsDenied(
          PermissionState previous, PermissionState current) =>
      (current.status[Permission.notification]?.isDeniedOrPermenantlyDenied ??
          false) &&
      !(previous.status[Permission.notification]?.isDeniedOrPermenantlyDenied ??
          false);
}
