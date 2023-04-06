import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/background/all.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

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
          listener: (context, state) async {
            _log.fine('remote alarm stop: ${state.data}');
            final hash = state.stopAlarmSoundKey;
            final stackId = state.popAlarmKey;
            if (stackId != null) {
              _log.info('trying to pop alarm with id: $stackId');
              final route =
                  GetIt.I<AlarmNavigator>().removedFromRoutes(stackId);
              if (route != null && context.mounted) {
                Navigator.of(context).removeRoute(route);
              }
            }
            if (hash != null) {
              _log.info('canceling alarm with id: $hash');
              return notificationPlugin.cancel(hash);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
