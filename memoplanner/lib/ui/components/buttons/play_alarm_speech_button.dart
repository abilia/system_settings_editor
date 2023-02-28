import 'package:get_it/get_it.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/ui/all.dart';

class PlayAlarmSpeechButton extends StatelessWidget {
  final NewAlarm alarm;
  const PlayAlarmSpeechButton({
    required this.alarm,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => SoundBloc(
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
                        soundBloc: context.read<SoundBloc>(),
                        touchStream: context.read<TouchDetectionCubit>().stream,
                        selectedNotificationStream:
                            Config.isMPGO ? selectNotificationSubject : null,
                        remoteMessageStream: context.read<PushCubit>().stream,
                      ),
                      lazy: false,
                      child: const SizedBox.shrink(),
                    ),
            ),
          ],
        ),
      );
}
