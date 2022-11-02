import 'package:get_it/get_it.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

class PlayAlarmSpeechButton extends StatelessWidget {
  final NewAlarm alarm;
  const PlayAlarmSpeechButton({
    required this.alarm,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => SoundCubit(
          storage: GetIt.I<FileStorage>(),
          userFileCubit: context.read<UserFileCubit>(),
        ),
        child: Row(
          children: [
            PlaySoundButton(sound: alarm.speech),
            BlocBuilder<MemoplannerSettingsBloc, MemoplannerSettings>(
              builder: (context, settings) => settings
                      is MemoplannerSettingsNotLoaded
                  ? const SizedBox.shrink()
                  : BlocProvider(
                      create: (context) => AlarmSpeechCubit(
                        alarm: alarm,
                        now: () => GetIt.I<Ticker>().time,
                        alarmSettings: settings.alarm,
                        soundCubit: context.read<SoundCubit>(),
                        touchStream: context.read<TouchDetectionCubit>().stream,
                        selectedNotificationStream:
                            Config.isMPGO ? selectNotificationSubject : null,
                      ),
                      lazy: false,
                      child: const SizedBox.shrink(),
                    ),
            ),
          ],
        ),
      );
}
