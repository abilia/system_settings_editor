import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/notification/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmListener extends StatelessWidget {
  final Widget child;

  const AlarmListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (settingsState) =>
          settingsState.alarm.showOngoingActivityInFullScreen,
      builder: (context, fullScreenActivity) => MultiBlocListener(
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
                current.data.containsKey(AlarmCanceler.cancelAlarmKey),
            listener: (context, state) {
              final id = state.alarmKey;
              if (id != null) notificationPlugin.cancel(id);
            },
          ),
        ],
        child: child,
      ),
    );
  }
}
