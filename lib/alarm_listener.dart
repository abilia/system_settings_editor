import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

class SeagullListeners extends StatefulWidget {
  const SeagullListeners({
    Key key,
    @required this.child,
    this.listenWhen,
  }) : super(key: key);

  final Widget child;
  final BlocListenerCondition<AlarmStateBase> listenWhen;

  @override
  _SeagullListenersState createState() => _SeagullListenersState();
}

class _SeagullListenersState extends State<SeagullListeners>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BlocProvider.of<LicenseBloc>(context).add(ReloadLicenses());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActivitiesBloc, ActivitiesState>(
          listener: (context, state) async {
            if (state is ActivitiesLoaded) {
              await GetIt.I<AlarmScheduler>()(
                state.activities,
                Localizations.localeOf(context).toLanguageTag(),
                MediaQuery.of(context).alwaysUse24HourFormat,
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
            listenWhen: (previous, current) =>
                current.status[Permission.notification].isDenied &&
                !previous.status[Permission.notification].isDenied,
            listener: (context, state) => showViewDialog(
                  context: context,
                  builder: (context) => NotificationPermissionWarningDialog(),
                )),
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
