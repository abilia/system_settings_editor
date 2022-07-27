import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityGeneralSettingsTab extends StatelessWidget {
  const AddActivityGeneralSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocSelector<AddActivitySettingsCubit, AddActivitySettingsState,
            AddActivitySettings>(
        selector: (state) => state.addActivitySetting,
        builder: (context, settings) {
          return SettingsTab(
            children: [
              Tts(child: Text(t.general)),
              SwitchField(
                leading:
                    const Icon(AbiliaIcons.clock),
                value: settings.allowPassedStartTime,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(
                        settings.copyWith(allowPassedStartTime: v)),
                child: Text(t.allowPassedStartTime),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.week),
                value: settings.addRecurringActivity,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(
                        settings.copyWith(addRecurringActivity: v)),
                child: Text(t.addRecurringActivity),
              ),
              SwitchField(
                leading:
                    const Icon(AbiliaIcons.endTime),
                value: settings.showEndTime,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(settings.copyWith(showEndTime: v)),
                child: Text(t.showEndTime),
              ),
              const SizedBox(),
              SwitchField(
                leading: const Icon(AbiliaIcons.handiAlarmVibration),
                value: settings.showAlarm,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(settings.copyWith(showAlarm: v)),
                child: Text(t.showAlarm),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.handiVibration),
                value: settings.showVibrationAlarm,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(
                        settings.copyWith(showVibrationAlarm: v)),
                child: Text(t.showVibrationAlarm),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.handiAlarm),
                value: settings.showSilentAlarm,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(settings.copyWith(showSilentAlarm: v)),
                child: Text(t.showSilentAlarm),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.handiNoAlarm),
                value: settings.showNoAlarm,
                onChanged: (v) => context
                    .read<AddActivitySettingsCubit>()
                    .addActivitySetting(settings.copyWith(showNoAlarm: v)),
                child: Text(t.showNoAlarm),
              ),
            ],
          );
        });
  }
}
