import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/calendar/add_activity/add_activity_settings_cubit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityDefaultSettingsTab extends StatelessWidget {
  const AddActivityDefaultSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;

    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
        builder: (context, state) {
      final onAlarmTypeChanged = (AlarmType alarmType) => context
          .read<AddActivitySettingsCubit>()
          .changeAddActivitySettings(state.copyWith(
              defaultsTabSettingsState: state.defaultsTabSettingsState
                  .copyWith(alarmType: alarmType)));
      return SettingsTab(
        children: [
          Tts(child: Text(t.defaults)),
          RadioField(
            value: AlarmType.SoundAndVibration,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.alarmAndVibration),
            leading: Icon(
              AbiliaIcons.handi_alarm_vibration,
            ),
          ),
          RadioField(
            value: AlarmType.Vibration,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.vibration),
            leading: Icon(
              AbiliaIcons.handi_vibration,
            ),
          ),
          RadioField(
            value: AlarmType.Silent,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.silentAlarm),
            leading: Icon(
              AbiliaIcons.handi_alarm,
            ),
          ),
          RadioField(
            value: AlarmType.NoAlarm,
            groupValue: state.defaultsTabSettingsState.alarmType,
            onChanged: onAlarmTypeChanged,
            text: Text(t.noAlarm),
            leading: Icon(
              AbiliaIcons.handi_no_alarm_vibration,
            ),
          ),
          Divider(),
          SwitchField(
            leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
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
