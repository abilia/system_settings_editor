import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AddActivityGeneralSettingsTab extends StatelessWidget {
  const AddActivityGeneralSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final generalSettings =
        context.select((AddActivitySettingsCubit cubit) => cubit.state.general);
    return SettingsTab(
      children: [
        Tts(child: Text(translate.time)),
        SwitchField(
          leading: const Icon(AbiliaIcons.clock),
          value: generalSettings.allowPassedStartTime,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(allowPassedStartTime: v)),
          child: Text(translate.allowPassedStartTime),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.endTime),
          value: generalSettings.showEndTime,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showEndTime: v)),
          child: Text(translate.showEndTime),
        ),
        const Divider(),
        Tts(child: Text(translate.alarm)),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarmVibration),
          value: generalSettings.showAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showAlarm: v)),
          child: Text(translate.showAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiVibration),
          value: generalSettings.showVibrationAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showVibrationAlarm: v)),
          child: Text(translate.showVibrationAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: generalSettings.showSilentAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showSilentAlarm: v)),
          child: Text(translate.showSilentAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiNoAlarm),
          value: generalSettings.showNoAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(generalSettings.copyWith(showNoAlarm: v)),
          child: Text(translate.showNoAlarm),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: generalSettings.showAlarmOnlyAtStart,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showAlarmOnlyAtStart: v)),
          child: Text(translate.showAlarmOnlyAtStartTime),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.dictaphone),
          value: generalSettings.showSpeechAtAlarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(showSpeechAtAlarm: v)),
          child: Text(translate.showSpeechAtAlarm),
        ),
        const Divider(),
        Tts(child: Text(translate.recurring)),
        SwitchField(
          leading: const Icon(AbiliaIcons.week),
          value: generalSettings.addRecurringActivity,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addGeneralSettings(
                  generalSettings.copyWith(addRecurringActivity: v)),
          child: Text(translate.addRecurringActivity),
        ),
      ],
    );
  }
}
