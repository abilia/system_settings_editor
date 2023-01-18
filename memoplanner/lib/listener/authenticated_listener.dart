import 'package:get_it/get_it.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/utils/all.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    GetIt.I<SettingsDb>()
        .setAlwaysUse24HourFormat(MediaQuery.of(context).alwaysUse24HourFormat);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      GetIt.I<SettingsDb>().setAlwaysUse24HourFormat(
          MediaQuery.of(context).alwaysUse24HourFormat);
      context
        ..read<ClockBloc>().setTime(DateTime.now())
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
        BlocListener<ActivitiesBloc, ActivitiesChanged>(
          listener: (context, state) =>
              context.read<NotificationBloc>().add(NotificationEvent()),
        ),
        BlocListener<MemoplannerSettingsBloc, MemoplannerSettings>(
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
          listener: (context, state) {
            if (Config.isMP && state is NoValidLicense) {
              showViewDialog(
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
          listener: (context, state) => showViewDialog(
              context: context,
              builder: (context) => const NotificationPermissionWarningDialog(),
              routeSettings:
                  (NotificationPermissionWarningDialog).routeSetting()),
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
      text: Translator.of(context).translate.licenseExpiredMessage,
    );
  }
}
