import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class RecordSoundWidget extends StatelessWidget {
  final Activity activity;

  const RecordSoundWidget(this.activity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.abilityToSelectAlarm != current.abilityToSelectAlarm,
      builder: (context, memoSettingsState) => BlocProvider(
        create: (context) => SoundCubit(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.speech),
            SelectOrPlaySoundWidget(
              label: translator.speechOnStart,
              abilityToSelectAlarm: memoSettingsState.abilityToSelectAlarm,
              recordedAudio: activity.extras.startTimeExtraAlarm,
              onResult: (AbiliaFile result) {
                BlocProvider.of<EditActivityBloc>(context).add(
                  ReplaceActivity(
                    activity.copyWith(
                      extras: activity.extras.copyWith(
                        startTimeExtraAlarm: result,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 8.0.s),
            SelectOrPlaySoundWidget(
              label: translator.speechOnEnd,
              abilityToSelectAlarm: memoSettingsState.abilityToSelectAlarm,
              recordedAudio: activity.extras.endTimeExtraAlarm,
              onResult: (AbiliaFile result) {
                BlocProvider.of<EditActivityBloc>(context).add(
                  ReplaceActivity(
                    activity.copyWith(
                      extras: activity.extras.copyWith(
                        endTimeExtraAlarm: result,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SelectOrPlaySoundWidget extends StatelessWidget {
  final bool abilityToSelectAlarm;
  final String label;
  final AbiliaFile recordedAudio;
  final ValueChanged<UnstoredAbiliaFile> onResult;

  const SelectOrPlaySoundWidget({
    Key? key,
    required this.abilityToSelectAlarm,
    required this.label,
    required this.recordedAudio,
    required this.onResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) {
        final permission = permissionState.status[Permission.microphone];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: PickField(
                leading: Icon(recordedAudio.isEmpty
                    ? AbiliaIcons.no_record
                    : AbiliaIcons.sms_sound),
                text: Text(label),
                onTap: abilityToSelectAlarm &&
                        permission?.isPermanentlyDenied == false
                    ? () async {
                        if (permission?.isGranted != true) {
                          context
                              .read<PermissionBloc>()
                              .add(RequestPermissions([Permission.microphone]));
                          return;
                        }
                        final result = await Navigator.of(context)
                            .push<UnstoredAbiliaFile>(
                          MaterialPageRoute(
                            builder: (_) => CopiedAuthProviders(
                              blocContext: context,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (_) => SoundCubit()),
                                  BlocProvider(
                                    create: (_) => RecordSoundCubit(
                                      originalSoundFile: recordedAudio,
                                    ),
                                  ),
                                ],
                                child: const RecordSoundPage(),
                              ),
                            ),
                            settings: RouteSettings(name: 'SelectSpeechPage'),
                          ),
                        );
                        if (result != null) {
                          context.read<UserFileBloc>().add(FileAdded(result));
                        }
                        if (result != null) {
                          onResult.call(result);
                        }
                      }
                    : null,
              ),
            ),
            if (permission?.isPermanentlyDenied == true)
              Padding(
                padding: EdgeInsets.only(left: 8.0.s),
                child: InfoButton(
                  onTap: () => showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) =>
                        PermissionInfoDialog(permission: Permission.microphone),
                  ),
                ),
              ),
            if (recordedAudio.isNotEmpty)
              BlocBuilder<UserFileBloc, UserFileState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.only(left: 12.s),
                    child: PlaySoundButton(
                      sound: state.getFile(
                        recordedAudio,
                        GetIt.I<FileStorage>(),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class RecordingWidget extends StatelessWidget {
  const RecordingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.s),
      child: BlocBuilder<SoundCubit, SoundState>(
        builder: (context, soundState) =>
            BlocBuilder<RecordSoundCubit, RecordSoundState>(
          builder: (context, recordState) {
            final progress = recordState is RecordingSoundState
                ? recordState.progress
                : soundState is SoundPlaying
                    ? soundState.progress
                    : 0.0;
            final duration = recordState is RecordingSoundState
                ? recordState.duration
                : soundState is SoundPlaying
                    ? soundState.position
                    : Duration.zero;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TimeDisplay(timeElapsed: duration),
                SizedBox(height: 8.0.s),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AbiliaColors.white120,
                  valueColor: AlwaysStoppedAnimation(
                    recordState is RecordingSoundState
                        ? AbiliaColors.red
                        : AbiliaColors.black,
                  ),
                  minHeight: 6.s,
                ),
                SizedBox(height: 24.0.s),
                const _RecordActionRow(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecordActionRow extends StatelessWidget {
  const _RecordActionRow();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoundCubit, SoundState>(
      builder: (context, soundState) {
        return BlocBuilder<RecordSoundCubit, RecordSoundState>(
          builder: (context, recordState) {
            return Row(
              children: [
                if (recordState is RecordedSoundState)
                  if (soundState is SoundPlaying)
                    Expanded(
                      child: StopButton(
                        onPressed: context.read<SoundCubit>().stopSound,
                      ),
                    )
                  else ...[
                    Expanded(
                      child: PlayRecordingButton(recordState.recordedFile),
                    ),
                    SizedBox(width: 12.s),
                    const DeleteButton()
                  ],
                if (recordState is RecordingSoundState)
                  Expanded(
                    child: StopButton(
                      onPressed: context.read<RecordSoundCubit>().stopRecording,
                    ),
                  )
                else if (recordState is EmptyRecordSoundState)
                  Expanded(child: const RecordAudioButton())
              ],
            );
          },
        );
      },
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final Duration timeElapsed;

  _TimeDisplay({this.timeElapsed = Duration.zero});

  @override
  Widget build(BuildContext context) {
    var timeText = _formatTime(timeElapsed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(Translator.of(context).translate.duration),
        Container(
          width: 120.s,
          height: 64.s,
          decoration: disabledBoxDecoration,
          child: Center(
            child: Text(
              timeText,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(Duration d) {
    return d.toString().substring(5, 10).replaceAll('.', ':');
  }
}

class RecordAudioButton extends StatelessWidget {
  const RecordAudioButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: Translator.of(context).translate.record,
        icon: AbiliaIcons.dictaphone,
        onPressed: context.read<RecordSoundCubit>().startRecording,
        style: iconTextButtonStyleRed,
      );
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ActionButtonDark(
        onPressed: () => context.read<RecordSoundCubit>().deleteRecording(),
        child: Icon(AbiliaIcons.delete_all_clear),
      );
}

class StopButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StopButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkGreyButton(
      text: Translator.of(context).translate.stop,
      icon: AbiliaIcons.stop,
      onPressed: onPressed,
    );
  }
}

class PlayRecordingButton extends StatelessWidget {
  final AbiliaFile sound;
  const PlayRecordingButton(
    this.sound, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkGreyButton(
        text: Translator.of(context).translate.play,
        icon: AbiliaIcons.play_sound,
        onPressed: () => context.read<SoundCubit>().play(sound));
  }
}
