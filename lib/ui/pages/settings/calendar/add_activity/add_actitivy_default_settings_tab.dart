import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/calendar/add_activity/add_activity_settings_cubit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityDefaultSettingsTab extends StatelessWidget {
  const AddActivityDefaultSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
        builder: (context, state) {
      onAlarmTypeChanged(AlarmType? alarmType) => context
          .read<AddActivitySettingsCubit>()
          .changeAddActivitySettings(state.copyWith(
              defaultsTabSettingsState: state.defaultsTabSettingsState
                  .copyWith(alarmType: alarmType)));
      return SettingsTab(
        children: [
          Tts(child: Text(t.defaults)),
          RadioField(
            value: AlarmType.soundAndVibration,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.alarmAndVibration),
            leading: const Icon(
              AbiliaIcons.handiAlarmVibration,
            ),
          ),
          RadioField(
            value: AlarmType.vibration,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.vibration),
            leading: const Icon(
              AbiliaIcons.handiVibration,
            ),
          ),
          RadioField(
            value: AlarmType.silent,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.silentAlarm),
            leading: const Icon(
              AbiliaIcons.handiAlarm,
            ),
          ),
          RadioField(
            value: AlarmType.noAlarm,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.noAlarm),
            leading: const Icon(
              AbiliaIcons.handiNoAlarmVibration,
            ),
          ),
          const Divider(),
          SwitchField(
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
            value: state.defaultsTabSettingsState.alarmOnlyAtStartTime,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(
                    defaultsTabSettingsState: state.defaultsTabSettingsState
                        .copyWith(alarmOnlyAtStartTime: v))),
            child: Text(t.alarmOnlyAtStartTime),
          ),
        ],
      );
    });
  }
}
