import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityGeneralSettingsTab extends StatelessWidget {
  const AddActivityGeneralSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.general)),
          SwitchField(
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
            value: state.allowPassedStartTime,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(
                    state.copyWith(allowPassedStartTime: v)),
            child: Text(t.allowPassedStartTime),
          ),
          SwitchField(
            leading: const Icon(AbiliaIcons.week),
            value: state.addRecurringActivity,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(
                    state.copyWith(addRecurringActivity: v)),
            child: Text(t.addRecurringActivity),
          ),
          SwitchField(
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
            value: state.showEndTime,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showEndTime: v)),
            child: Text(t.showEndTime),
          ),
          const SizedBox(),
          SwitchField(
            leading: const Icon(AbiliaIcons.handiAlarmVibration),
            value: state.showAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showAlarm: v)),
            child: Text(t.showAlarm),
          ),
          SwitchField(
            leading: const Icon(AbiliaIcons.handiAlarm),
            value: state.showSilentAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showSilentAlarm: v)),
            child: Text(t.showSilentAlarm),
          ),
          SwitchField(
            leading: const Icon(AbiliaIcons.handiNoAlarm),
            value: state.showNoAlarm,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .changeAddActivitySettings(state.copyWith(showNoAlarm: v)),
            child: Text(t.showNoAlarm),
          ),
        ],
      ),
    );
  }
}
