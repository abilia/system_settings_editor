import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityDefaultSettingsTab extends StatelessWidget {
  const AddActivityDefaultSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
        builder: (context, state) {
      return SettingsTab(
        children: [
          Tts(child: Text(t.defaults)),
          RadioField(
            value: AlarmType.soundAndVibration,
            groupValue: state.defaultAlarm.type,
            onChanged:
                context.read<AddActivitySettingsCubit>().defaultAlarmType,
            text: Text(t.alarmAndVibration),
            leading: const Icon(
              AbiliaIcons.handiAlarmVibration,
            ),
          ),
          RadioField(
            value: AlarmType.vibration,
            groupValue: state.defaultAlarm.type,
            onChanged:
                context.read<AddActivitySettingsCubit>().defaultAlarmType,
            text: Text(t.vibration),
            leading: const Icon(
              AbiliaIcons.handiVibration,
            ),
          ),
          RadioField(
            value: AlarmType.silent,
            groupValue: state.defaultAlarm.type,
            onChanged:
                context.read<AddActivitySettingsCubit>().defaultAlarmType,
            text: Text(t.silentAlarm),
            leading: const Icon(
              AbiliaIcons.handiAlarm,
            ),
          ),
          RadioField(
            value: AlarmType.noAlarm,
            groupValue: state.defaultAlarm.type,
            onChanged:
                context.read<AddActivitySettingsCubit>().defaultAlarmType,
            text: Text(t.noAlarm),
            leading: const Icon(
              AbiliaIcons.handiNoAlarmVibration,
            ),
          ),
          const Divider(),
          SwitchField(
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
            value: state.defaultAlarm.onlyStart,
            onChanged: (v) => context.read<AddActivitySettingsCubit>().change(
                state.copyWith(
                    defaultAlarm: state.defaultAlarm.copyWith(onlyStart: v))),
            child: Text(t.alarmOnlyAtStartTime),
          ),
        ],
      );
    });
  }
}
