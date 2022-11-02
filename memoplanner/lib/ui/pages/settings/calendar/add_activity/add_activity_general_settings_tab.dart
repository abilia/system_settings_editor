import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityGeneralSettingsTab extends StatelessWidget {
  const AddActivityGeneralSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final generalSettings =
        context.select((AddActivitySettingsCubit cubit) => cubit.state.general);
    return SettingsTab(
      children: [
        Tts(child: Text(t.time)),
        SwitchField(
          leading: const Icon(AbiliaIcons.clock),
          value: generalSettings.allowPassedStartTime,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(allowPassedStartTime: v)),
          child: Text(t.allowPassedStartTime),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.endTime),
          value: generalSettings.showEndTime,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showEndTime: v)),
          child: Text(t.showEndTime),
        ),
        const Divider(),
        Tts(child: Text(t.alarm)),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarmVibration),
          value: generalSettings.showAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showAlarm: v)),
          child: Text(t.showAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiVibration),
          value: generalSettings.showVibrationAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showVibrationAlarm: v)),
          child: Text(t.showVibrationAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: generalSettings.showSilentAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showSilentAlarm: v)),
          child: Text(t.showSilentAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiNoAlarm),
          value: generalSettings.showNoAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showNoAlarm: v)),
          child: Text(t.showNoAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: generalSettings.showAlarmOnlyAtStart,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showAlarmOnlyAtStart: v)),
          child: Text(t.showAlarmOnlyAtStartTime),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.dictaphone),
          value: generalSettings.showSpeechAtAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showSpeechAtAlarm: v)),
          child: Text(t.showSpeechAtAlarm),
        ),
        const Divider(),
        Tts(child: Text(t.recurring)),
        SwitchField(
          leading: const Icon(AbiliaIcons.week),
          value: generalSettings.addRecurringActivity,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(addRecurringActivity: v)),
          child: Text(t.addRecurringActivity),
        ),
      ],
    );
  }
}
