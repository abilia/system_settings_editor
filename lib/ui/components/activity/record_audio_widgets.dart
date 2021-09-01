import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/edit_activity/record_speech_page.dart';
import 'package:seagull/utils/all.dart';

class RecordAudioWidget extends StatelessWidget {
  final Activity activity;

  const RecordAudioWidget(this.activity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.abilityToSelectAlarm != current.abilityToSelectAlarm,
      builder: (context, memoSettingsState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(translator.speech),
          RecordAndPlayAudio(
            activity: activity,
            label: translator.speechOnStart,
            memoSettingsState: memoSettingsState,
            onAudioRecordedCallback: (UserFile? result) {
              BlocProvider.of<EditActivityBloc>(context).add(
                ReplaceActivity(
                  activity.copyWith(
                    extras: activity.extras.copyWith(
                        startTimeExtraAlarm: result != null ? result.path : '',
                        startTimeExtraAlarmFileId:
                            result != null ? result.id : ''),
                  ),
                ),
              );
            },
            recordedAudio: activity.extras.startTimeExtraAlarm,
          ),
          SizedBox(height: 8.0.s),
          RecordAndPlayAudio(
            activity: activity,
            label: translator.speechOnEnd,
            memoSettingsState: memoSettingsState,
            onAudioRecordedCallback: (UserFile? result) {
              BlocProvider.of<EditActivityBloc>(context).add(
                ReplaceActivity(
                  activity.copyWith(
                    extras: activity.extras.copyWith(
                        endTimeExtraAlarm: result != null ? result.path : '',
                        endTimeExtraAlarmFileId:
                            result != null ? result.id : ''),
                  ),
                ),
              );
            },
            recordedAudio: activity.extras.endTimeExtraAlarm,
          ),
        ],
      ),
    );
  }
}

class RecordAndPlayAudio extends StatelessWidget {
  final Activity activity;
  final MemoplannerSettingsState memoSettingsState;
  final String label;
  final String recordedAudio;
  final ValueChanged<UserFile?> onAudioRecordedCallback;

  const RecordAndPlayAudio({
    Key? key,
    required this.activity,
    required this.memoSettingsState,
    required this.label,
    required this.recordedAudio,
    required this.onAudioRecordedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: PickField(
            key: key,
            leading: Icon(recordedAudio != ''
                ? AbiliaIcons.sms_sound
                : AbiliaIcons.no_record),
            text: Text(label),
            onTap: memoSettingsState.abilityToSelectAlarm
                ? () async {
                    final result = await Navigator.of(context)
                        .push<UserFile>(MaterialPageRoute(
                      builder: (_) => CopiedAuthProviders(
                        blocContext: context,
                        child:
                            RecordSpeechPage(originalSoundFile: recordedAudio),
                      ),
                      settings: RouteSettings(name: 'SelectSpeechPage'),
                    ));
                    onAudioRecordedCallback.call(result);
                  }
                : null,
          ),
        ),
      ],
    );

    if (recordedAudio != '') {
      var value = ActionButton(
          onPressed: () {}, child: Icon(AbiliaIcons.delete_all_clear));
      row.children.add(value);
    }

    return row;
  }
}
