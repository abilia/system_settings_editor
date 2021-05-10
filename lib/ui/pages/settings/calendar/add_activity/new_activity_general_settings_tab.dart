import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class NewActivityGeneralSettingsTab extends StatelessWidget {
  const NewActivityGeneralSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.general)),
          SwitchField(
            text: Text(t.allowPassedStartTime),
            leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
            value: state.allowPassedStartTime,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(
                    state.copyWith(allowPassedStartTime: v)),
          ),
          SwitchField(
            text: Text(t.addRecurringActivity),
            leading: Icon(AbiliaIcons.week),
            value: state.addRecurringActivity,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(
                    state.copyWith(addRecurringActivity: v)),
          ),
          SwitchField(
            text: Text(t.showEndTime),
            leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
            value: state.showEndTime,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showEndTime: v)),
          ),
          SizedBox(),
          SwitchField(
            text: Text(t.showAlarm),
            leading: Icon(AbiliaIcons.handi_alarm_vibration),
            value: state.showAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showAlarm: v)),
          ),
          SwitchField(
            text: Text(t.showSilentAlarm),
            leading: Icon(AbiliaIcons.handi_alarm),
            value: state.showSilentAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showSilentAlarm: v)),
          ),
          SwitchField(
            text: Text(t.showNoAlarm),
            leading: Icon(AbiliaIcons.handi_no_alarm),
            value: state.showNoAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showNoAlarm: v)),
          ),
        ],
      ),
    );
  }
}
