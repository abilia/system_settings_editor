import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmListener extends StatelessWidget {
  static final _log = Logger('AlarmListener');
  final Widget child;

  const AlarmListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullScreenActivity = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.alarm.showOngoingActivityInFullScreen);
    return MultiBlocListener(
      listeners: [
        BlocListener<AlarmCubit, NotificationAlarm?>(
          listener: (context, state) async {
            if (state != null) {
              await GetIt.I<AlarmNavigator>().pushAlarm(
                context,
                state.setFullScreenActivity(fullScreenActivity),
              );
            }
          },
        ),
        BlocListener<PushCubit, RemoteMessage>(
          listenWhen: (previous, current) =>
              current.data.containsKey(RemoteAlarm.stopSoundKey) ||
              current.data.containsKey(RemoteAlarm.popKey),
          listener: (context, state) {
            _log.fine('remote alarm stop: ${state.data}');
            final hash = state.stopAlarmSoundKey;
            if (hash != null) {
              _log.info('canceling alarm with id: $hash');
              notificationPlugin.cancel(hash);
            }
            final stackId = state.popAlarmKey;
            if (stackId != null) {
              _log.info('trying to pop alarm with id: $stackId');
              final route =
                  GetIt.I<AlarmNavigator>().removedFromRoutes(stackId);
              if (route != null) {
                Navigator.of(context).removeRoute(route);
              }
            }
          },
        ),
      ],
      child: child,
    );
  }
}
