import 'package:get_it/get_it.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

class PlayAlarmSpeechButton extends StatelessWidget {
  final NewAlarm alarm;
  final bool fullScreenAlarm;
  const PlayAlarmSpeechButton({
    Key? key,
    required this.alarm,
    required this.fullScreenAlarm,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SoundCubit(
              storage: GetIt.I<FileStorage>(),
              userFileBloc: context.read<UserFileBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => AlarmSpeechCubit(
              alarm: alarm,
              alarmSettings: context.read<MemoplannerSettingBloc>().state.alarm,
              soundCubit: context.read<SoundCubit>(),
              selectedNotificationStream: selectNotificationSubject,
            ),
            lazy: false,
          ),
        ],
        child: PlaySoundButton(
          sound: alarm.speech,
        ),
      );
}
