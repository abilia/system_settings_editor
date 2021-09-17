import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/buttons/green_play_button.dart';

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
  final ValueChanged<AbiliaFile> onResult;

  const SelectOrPlaySoundWidget({
    Key? key,
    required this.abilityToSelectAlarm,
    required this.label,
    required this.recordedAudio,
    required this.onResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var permission = Permission.microphone;
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) {
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
                        permissionState.microphoneDenied == false
                    ? () async {
                        final result =
                            await Navigator.of(context).push<AbiliaFile>(
                          MaterialPageRoute(
                            builder: (_) => CopiedAuthProviders(
                              blocContext: context,
                              child: BlocProvider(
                                create: (context) => RecordSoundCubit(
                                  originalSoundFile: recordedAudio,
                                ),
                                child: RecordSoundPage(
                                  originalSoundFile: recordedAudio,
                                ),
                              ),
                            ),
                            settings: RouteSettings(name: 'SelectSpeechPage'),
                          ),
                        );
                        if (result is UnstoredAbiliaFile && result.isNotEmpty) {
                          context.read<UserFileBloc>().add(
                                FileAdded(result),
                              );
                        }
                        if (result != null) {
                          onResult.call(result);
                        }
                      }
                    : null,
              ),
            ),
            if (permissionState.microphoneDenied == true)
              Padding(
                padding: EdgeInsets.only(left: 8.0.s),
                child: InfoButton(
                  onTap: () => showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) =>
                        PermissionInfoDialog(permission: permission),
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

class RecordingWidget extends StatefulWidget {
  final RecordSoundState state;

  const RecordingWidget({
    required this.state,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecordingWidgetState(state: state);
  }
}

class _RecordingWidgetState extends State<RecordingWidget> {
  RecordSoundState state;

  _RecordingWidgetState({required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordSoundCubit, RecordSoundState>(
      listener: (context, state) {
        setState(() {
          this.state = state;
        });
      },
      child: BlocProvider(
        create: (_) => SoundCubit(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TimeDisplay(
                timeElapsed: context
                    .select((TimerBloc bloc) => bloc.state.duration / 1000.0),
              ),
              _TimeProgressIndicator(
                  context.select((TimerBloc bloc) =>
                      bloc.state.duration / bloc.maxDuration),
                  AlwaysStoppedAnimation(Colors.red)),
              SizedBox(height: 24.0.s),
              _getActionRow(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getActionRow(RecordSoundState state) {
    if (state is StoppedSoundState) {
      return state.recordedFile.isEmpty
          ? StoppedEmptyStateWidget()
          : StoppedNotEmptyStateWidget(recordedFile: state.recordedFile);
    } else if (state is RecordingSoundState) {
      return RecordingStateWidget();
    }
    return StoppedEmptyStateWidget();
  }
}

class _TimeDisplay extends StatelessWidget {
  final double timeElapsed;
  final double _millisPerSecond = 1000.0;

  _TimeDisplay({this.timeElapsed = 0.0});

  @override
  Widget build(BuildContext context) {
    var seconds = timeElapsed.floor();
    var milliseconds = ((timeElapsed - seconds) * _millisPerSecond).floor();
    final duration = Duration(seconds: seconds, milliseconds: milliseconds);
    var timeText = _formatTime(duration);
    final translator = Translator.of(context).translate;
    return (Container(
      width: 120.s,
      height: 120.s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translator.duration,
            textAlign: TextAlign.left,
          ),
          TextField(
            readOnly: true,
            enabled: true,
            keyboardType: TextInputType.number,
            showCursor: false,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(labelText: timeText),
          ),
          SizedBox(height: 8.0.s),
        ],
      ),
    ));
  }

  String _formatTime(Duration d) {
    return d.toString().substring(5, 10).replaceAll('.', ':');
  }
}

class _TimeProgressIndicator extends LinearProgressIndicator {
  const _TimeProgressIndicator(double value, Animation<Color> anim)
      : super(
            value: value,
            backgroundColor: Colors.grey,
            valueColor: anim,
            minHeight: 6);
}

class RecordingStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: StopButton(
              onPressed: () {
                context.read<RecordSoundCubit>().stopRecording(
                    context.read<TimerBloc>().maxDuration / 1000);
                context.read<TimerBloc>().add(
                      TimerPaused(),
                    );
              },
            ),
          ),
        ]);
  }
}

class StoppedEmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RecordAudioButton(
            onPressed: () {
              context.read<RecordSoundCubit>().startRecording();
              context.read<TimerBloc>().add(
                    TimerStarted(duration: 30000),
                  );
            },
          ),
        ),
      ],
    );
  }
}

class StoppedNotEmptyStateWidget extends StatelessWidget {
  final AbiliaFile recordedFile;

  const StoppedNotEmptyStateWidget({required this.recordedFile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SoundCubit, SoundState>(
      listener: (context, state) {
        state.currentSound != null
            ? context.read<TimerBloc>().add(
                  TimerStarted(duration: 30000),
                )
            : context.read<TimerBloc>().add(
                  TimerReset(),
                );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GreenPlaySoundButton(
              sound: recordedFile is UnstoredAbiliaFile
                  ? (recordedFile as UnstoredAbiliaFile).file
                  : context.read<UserFileBloc>().state.getFile(
                        recordedFile,
                        GetIt.I<FileStorage>(),
                      ),
            ),
          ),
          ActionButton(
            onPressed: () {
              recordedFile is UnstoredAbiliaFile
                  ? (recordedFile as UnstoredAbiliaFile).file.delete()
                  : (context.read<UserFileBloc>().state.getFile(
                            recordedFile,
                            GetIt.I<FileStorage>(),
                          ))!
                      .delete();
              context.read<RecordSoundCubit>().deleteRecording();
              context.read<TimerBloc>().add(
                    TimerReset(),
                  );
            },
            child: Icon(AbiliaIcons.delete_all_clear),
          ),
        ],
      ),
    );
  }
}
