import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/utils/all.dart';

class AlarmListener extends StatelessWidget {
  const AlarmListener({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

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
        BlocListener<AlarmBloc, AlarmStateBase>(
          listener: _alarmListener,
        ),
        BlocListener<NotificationBloc, AlarmStateBase>(
          listener: _alarmListener,
        ),
      ],
      child: child,
    );
  }

  void _alarmListener(BuildContext context, AlarmStateBase state) async {
    if (state is AlarmState) {
      await GetIt.I<AlarmNavigator>().pushAlarm(context, state.alarm);
    }
  }
}
