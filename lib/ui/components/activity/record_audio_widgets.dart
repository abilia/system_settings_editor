import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class RecordAudioWidget extends StatelessWidget {
  final Activity activity;

  const RecordAudioWidget(this.activity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocProvider(
      create: (context) => SoundCubit(),
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.abilityToSelectAlarm != current.abilityToSelectAlarm,
        builder: (context, memoSettingsState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.speech),
            RecordAndPlayAudio(
              label: translator.speechOnStart,
              abilityToSelectAlarm: memoSettingsState.abilityToSelectAlarm,
              recordedAudio: activity.extras.startTimeExtraAlarm,
              onAudioRecordedCallback: (AbiliaFile? result) {
                if (result != null) {
                  BlocProvider.of<EditActivityBloc>(context).add(
                    ReplaceActivity(
                      activity.copyWith(
                        extras: activity.extras.copyWith(
                          startTimeExtraAlarm: result,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 8.0.s),
            RecordAndPlayAudio(
              label: translator.speechOnEnd,
              abilityToSelectAlarm: memoSettingsState.abilityToSelectAlarm,
              recordedAudio: activity.extras.endTimeExtraAlarm,
              onAudioRecordedCallback: (AbiliaFile? result) {
                if (result != null) {
                  BlocProvider.of<EditActivityBloc>(context).add(
                    ReplaceActivity(
                      activity.copyWith(
                        extras: activity.extras.copyWith(
                          endTimeExtraAlarm: result,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RecordAndPlayAudio extends StatelessWidget {
  final bool abilityToSelectAlarm;
  final String label;
  final AbiliaFile recordedAudio;
  final ValueChanged<AbiliaFile?> onAudioRecordedCallback;

  const RecordAndPlayAudio({
    Key? key,
    required this.abilityToSelectAlarm,
    required this.label,
    required this.recordedAudio,
    required this.onAudioRecordedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: PickField(
            leading: Icon(recordedAudio.isEmpty
                ? AbiliaIcons.sms_sound
                : AbiliaIcons.no_record),
            text: Text(label),
            onTap: abilityToSelectAlarm
                ? () async {
                    final result = await Navigator.of(context).push<AbiliaFile>(
                      MaterialPageRoute(
                        builder: (_) => CopiedAuthProviders(
                          blocContext: context,
                          child: RecordSpeechPage(
                            originalSoundFile: recordedAudio,
                          ),
                        ),
                        settings: RouteSettings(name: 'SelectSpeechPage'),
                      ),
                    );
                    if (result is UnstoredAbiliaFile) {
                      context.read<UserFileBloc>().add(RecordingAdded(result));
                    }
                    onAudioRecordedCallback.call(result);
                  }
                : null,
          ),
        ),
        if (recordedAudio.isNotEmpty)
          BlocBuilder<UserFileBloc, UserFileState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(left: 12.s),
                child: PlaySoundButton(
                    sound:
                        state.getFile(recordedAudio, GetIt.I<FileStorage>())),
              );
            },
          ),
      ],
    );
  }
}
