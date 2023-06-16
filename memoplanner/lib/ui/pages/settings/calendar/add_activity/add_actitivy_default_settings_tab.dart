import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class AddActivityDefaultSettingsTab extends StatelessWidget {
  const AddActivityDefaultSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final defaultsSettings = context
        .select((AddActivitySettingsCubit cubit) => cubit.state.defaults);
    final showAvailableFor = context
        .select((SupportPersonsCubit cubit) => cubit.state.showAvailableFor);

    return SettingsTab(
      children: [
        SwitchField(
          leading: const Icon(AbiliaIcons.handiCheck),
          value: defaultsSettings.checkable,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(defaultsSettings.copyWith(checkable: v)),
          child: Text(translate.checkable),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.deleteAllClear),
          value: defaultsSettings.removeAtEndOfDay,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(
                  defaultsSettings.copyWith(removeAtEndOfDay: v)),
          child: Text(translate.deleteAfter),
        ),
        if (showAvailableFor) ...[
          const Divider(),
          Tts(child: Text(translate.availableFor)),
          RadioField(
            value: AvailableForType.onlyMe,
            groupValue: defaultsSettings.availableForType,
            onChanged: (AvailableForType? type) => context
                .read<AddActivitySettingsCubit>()
                .addDefaultsSettings(
                    defaultsSettings.copyWith(availableForType: type)),
            text: Text(translate.onlyMe),
            leading: const Icon(
              AbiliaIcons.lock,
            ),
          ),
          RadioField(
            value: AvailableForType.allSupportPersons,
            groupValue: defaultsSettings.availableForType,
            onChanged: (AvailableForType? type) => context
                .read<AddActivitySettingsCubit>()
                .addDefaultsSettings(
                    defaultsSettings.copyWith(availableForType: type)),
            text: Text(translate.allSupportPersons),
            leading: const Icon(
              AbiliaIcons.unlock,
            ),
          ),
        ],
        const Divider(),
        Tts(child: Text(translate.alarm)),
        RadioField(
          value: AlarmType.soundAndVibration,
          groupValue: defaultsSettings.alarm.type,
          onChanged: (AlarmType? type) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(defaultsSettings.copyWith(
                  alarm: defaultsSettings.alarm.copyWith(type: type))),
          text: Text(translate.alarmAndVibration),
          leading: const Icon(
            AbiliaIcons.handiAlarmVibration,
          ),
        ),
        RadioField(
          value: AlarmType.vibration,
          groupValue: defaultsSettings.alarm.type,
          onChanged: (AlarmType? type) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(defaultsSettings.copyWith(
                  alarm: defaultsSettings.alarm.copyWith(type: type))),
          text: Text(translate.vibrationIfAvailable),
          leading: const Icon(
            AbiliaIcons.handiVibration,
          ),
        ),
        RadioField(
          value: AlarmType.silent,
          groupValue: defaultsSettings.alarm.type,
          onChanged: (AlarmType? type) =>
              context.read<AddActivitySettingsCubit>().addDefaultsSettings(
                    defaultsSettings.copyWith(
                      alarm: defaultsSettings.alarm.copyWith(
                        type: type,
                      ),
                    ),
                  ),
          text: Text(translate.silentAlarm),
          leading: const Icon(
            AbiliaIcons.handiAlarm,
          ),
        ),
        RadioField(
          value: AlarmType.noAlarm,
          groupValue: defaultsSettings.alarm.type,
          onChanged: (AlarmType? type) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(defaultsSettings.copyWith(
                  alarm: defaultsSettings.alarm.copyWith(type: type))),
          text: Text(translate.noAlarm),
          leading: const Icon(
            AbiliaIcons.handiNoAlarmVibration,
          ),
        ),
        const SizedBox(),
        SwitchField(
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: defaultsSettings.alarm.onlyStart,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .addDefaultsSettings(defaultsSettings.copyWith(
                  alarm: defaultsSettings.alarm.copyWith(onlyStart: v))),
          child: Text(translate.alarmOnlyAtStartTime),
        ),
      ],
    );
  }
}
