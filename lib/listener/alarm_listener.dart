import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/notification/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmListener extends StatelessWidget {
  final Widget child;

  const AlarmListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (settingsState) =>
          settingsState.alarm.showOngoingActivityInFullScreen,
      builder: (context, fullScreenActivity) => MultiBlocListener(
        listeners: [
          BlocListener<NotificationCubit, NotificationAlarm?>(
            listener: (context, state) async {
              if (state != null) {
                await GetIt.I<AlarmNavigator>().pushAlarm(
                  context,
                  state.setFullScreenActivity(fullScreenActivity),
                );
              }
            },
          ),
          if (!Platform.isAndroid)
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
        ],
        child: child,
      ),
    );
  }
}
