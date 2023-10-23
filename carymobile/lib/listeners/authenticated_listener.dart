import 'package:audioplayers/audioplayers.dart';
import 'package:auth/bloc/authentication/authentication_bloc.dart';
import 'package:auth/bloc/license/license_cubit.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/background/notification.dart';
import 'package:carymessenger/bloc/alarm_page_bloc.dart';
import 'package:carymessenger/bloc/next_alarm_scheduler_bloc.dart';
import 'package:carymessenger/copied_providers.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/ui/pages/alarm/alarm_page.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull_clock/seagull_clock.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:user_files/user_files.dart';

class AuthenticatedListener extends StatefulWidget {
  final Widget child;

  const AuthenticatedListener({required this.child, super.key});

  @override
  State<AuthenticatedListener> createState() => _AuthenticatedListenerState();
}

class _AuthenticatedListenerState extends State<AuthenticatedListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await context.read<ClockCubit>().setTime(DateTime.now());
    }
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
        BlocListener<LicenseCubit, LicenseState>(
          listener: (context, state) async {
            if (state is! ValidLicense) {
              BlocProvider.of<AuthenticationBloc>(context).add(
                const LoggedOut(
                  loggedOutReason: LoggedOutReason.noLicense,
                ),
              );
            }
          },
        ),
        BlocListener<AlarmCubit, ActivityDay?>(
          listener: (context, state) async {
            if (state != null) {
              final authProviders = copiedAuthProviders(context);
              await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      ...authProviders,
                      BlocProvider(
                        create: (context) => AlarmPageBloc(
                          activity: state,
                          audioPlayer: GetIt.I<AudioPlayer>(),
                          storage: GetIt.I<FileStorage>(),
                          userFileBloc: context.read<UserFileBloc>(),
                          ttsHandler: GetIt.I<TtsHandler>(),
                        ),
                      ),
                    ],
                    child: const AlarmPage(),
                  ),
                ),
                (route) => route.isFirst,
              );
            }
          },
        ),
        BlocListener<NextAlarmSchedulerBloc, ActivityDay?>(
          listener: (context, state) async {
            if (state != null) {
              final plugin = GetIt.I<FlutterLocalNotificationsPlugin>();
              await scheduleNextAlarm(plugin, state);
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
