import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class AddActivityAddSettingsTab extends StatelessWidget {
  const AddActivityAddSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final newActivityMode =
        context.select((AddActivitySettingsCubit cubit) => cubit.state.mode);
    return SettingsTab(
      children: [
        Tts(child: Text(t.add)),
        RadioField(
          value: AddActivityMode.editView,
          groupValue: newActivityMode,
          onChanged: context.read<AddActivitySettingsCubit>().newActivityMode,
          text: Text(t.throughEditView),
          leading: const Icon(AbiliaIcons.editView),
        ),
        RadioField(
          value: AddActivityMode.stepByStep,
          groupValue: newActivityMode,
          onChanged: context.read<AddActivitySettingsCubit>().newActivityMode,
          text: Text(t.stepByStep),
          leading: const Icon(AbiliaIcons.stepByStep),
        ),
        const Divider(),
        if (newActivityMode == AddActivityMode.editView)
          const _EditActivitySettingsWidget()
        else
          const _StepByStepSettingsWidget(),
      ],
    );
  }
}

void _showErrorDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        text: Translator.of(context).translate.missingRequiredActivitySetting,
      ),
    );

class _EditActivitySettingsWidget extends StatelessWidget {
  const _EditActivitySettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final editActivitySettings = context
        .select((AddActivitySettingsCubit cubit) => cubit.state.editActivity);
    final showAvailableFor = context
        .select((SupportPersonsCubit cubit) => cubit.state.showAvailableFor);

    return Column(
      children: [
        SwitchField(
          key: TestKey.showTemplatesSwitch,
          leading: const Icon(AbiliaIcons.basicActivity),
          value: editActivitySettings.template,
          onChanged: (v) {
            if (v || _checkRequiredStates(editActivitySettings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(editActivitySettings.copyWith(template: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.showTemplates),
        ),
        SwitchField(
          key: TestKey.addActivitySelectNameSwitch,
          leading: const Icon(AbiliaIcons.selectTextSize),
          value: editActivitySettings.title,
          onChanged: (v) {
            if (v || _checkRequiredStates(editActivitySettings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(editActivitySettings.copyWith(title: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.selectName),
        ),
        SwitchField(
          key: TestKey.addActivitySelectImageSwitch,
          leading: const Icon(AbiliaIcons.myPhotos),
          value: editActivitySettings.image,
          onChanged: (v) {
            if (v || _checkRequiredStates(editActivitySettings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(editActivitySettings.copyWith(image: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.selectImage),
        ),
        SwitchField(
          key: TestKey.addActivitySelectDateSwitch,
          leading: const Icon(AbiliaIcons.month),
          value: editActivitySettings.date,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(date: v)),
          child: Text(t.selectDate),
        ),
        SwitchField(
          key: TestKey.addActivitySelectAllDaySwitch,
          leading: const Icon(AbiliaIcons.restore),
          value: editActivitySettings.fullDay,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(fullDay: v)),
          child: Text(t.selectAllDay),
        ),
        SwitchField(
          key: TestKey.addActivitySelectCheckableSwitch,
          leading: const Icon(AbiliaIcons.handiCheck),
          value: editActivitySettings.checkable,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(checkable: v)),
          child: Text(t.selectCheckable),
        ),
        SwitchField(
          key: TestKey.addActivityDeleteAfterSwitch,
          leading: const Icon(AbiliaIcons.deleteAllClear),
          value: editActivitySettings.removeAfter,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(removeAfter: v)),
          child: Text(t.deleteAfter),
        ),
        if (showAvailableFor)
          SwitchField(
            key: TestKey.addActivitySelectAvailableForSwitch,
            leading: const Icon(AbiliaIcons.passwordProtection),
            value: editActivitySettings.availability,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .editSettings(editActivitySettings.copyWith(availability: v)),
            child: Text(t.selectAvailableFor),
          ),
        SwitchField(
          key: TestKey.addActivitySelectAlarmSwitch,
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: editActivitySettings.alarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(alarm: v)),
          child: Text(t.selectAlarm),
        ),
        SwitchField(
          key: TestKey.addActivitySelectReminderSwitch,
          leading: const Icon(AbiliaIcons.handiReminder),
          value: editActivitySettings.reminders,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(reminders: v)),
          child: Text(t.selectReminder),
        ),
        SwitchField(
          key: TestKey.addActivitySelectChecklistSwitch,
          leading: const Icon(AbiliaIcons.radioCheckboxUnselected),
          value: editActivitySettings.checklist,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(checklist: v)),
          child: Text(t.selectChecklist),
        ),
        SwitchField(
          key: TestKey.addActivitySelectNoteSwitch,
          leading: const Icon(AbiliaIcons.note),
          value: editActivitySettings.notes,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .editSettings(editActivitySettings.copyWith(notes: v)),
          child: Text(t.selectNote),
        ),
      ]
          .map((c) => Padding(
              padding: EdgeInsets.only(
                bottom: layout.formPadding.verticalItemDistance,
              ),
              child: c))
          .toList(),
    );
  }

  bool _checkRequiredStates(EditActivitySettings settings) =>
      [
        settings.title,
        settings.image,
        settings.template,
      ].where((checked) => checked).length >
      1;
}

class _StepByStepSettingsWidget extends StatelessWidget {
  const _StepByStepSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final settings = context
        .select((AddActivitySettingsCubit cubit) => cubit.state.stepByStep);
    final showAvailableFor = context
        .select((SupportPersonsCubit cubit) => cubit.state.showAvailableFor);

    return Column(
      children: [
        SwitchField(
          key: TestKey.showTemplatesSwitch,
          leading: const Icon(AbiliaIcons.basicActivity),
          value: settings.template,
          onChanged: (v) {
            if (v || _checkRequiredStates(settings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(showBasicActivities: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.showTemplates),
        ),
        SwitchField(
          key: TestKey.addActivitySelectNameSwitch,
          leading: const Icon(AbiliaIcons.selectTextSize),
          value: settings.title,
          onChanged: (v) {
            if (v || _checkRequiredStates(settings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectName: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.selectName),
        ),
        SwitchField(
          key: TestKey.addActivitySelectImageSwitch,
          leading: const Icon(AbiliaIcons.myPhotos),
          value: settings.image,
          onChanged: (v) {
            if (v || _checkRequiredStates(settings)) {
              context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectImage: v));
            } else {
              _showErrorDialog(context);
            }
          },
          child: Text(t.selectImage),
        ),
        SwitchField(
          key: TestKey.addActivitySelectDateSwitch,
          leading: const Icon(AbiliaIcons.month),
          value: settings.date,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(setDate: v)),
          child: Text(t.selectDate),
        ),
        SwitchField(
          key: TestKey.addActivitySelectAllDaySwitch,
          leading: const Icon(AbiliaIcons.restore),
          value: settings.fullDay,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(showFullDay: v)),
          child: Text(t.selectAllDay),
        ),
        SwitchField(
          key: TestKey.addActivitySelectCheckableSwitch,
          leading: const Icon(AbiliaIcons.handiCheck),
          value: settings.checkable,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectCheckable: v)),
          child: Text(t.selectCheckable),
        ),
        SwitchField(
          key: TestKey.addActivityDeleteAfterSwitch,
          leading: const Icon(AbiliaIcons.deleteAllClear),
          value: settings.removeAfter,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectDeleteAfter: v)),
          child: Text(t.deleteAfter),
        ),
        if (showAvailableFor)
          SwitchField(
            key: TestKey.addActivitySelectAvailableForSwitch,
            leading: const Icon(AbiliaIcons.passwordProtection),
            value: settings.availability,
            onChanged: (v) => context
                .read<AddActivitySettingsCubit>()
                .stepByStepSetting(settings.copyWith(selectAvailableFor: v)),
            child: Text(t.selectAvailableFor),
          ),
        SwitchField(
          key: TestKey.addActivitySelectAlarmSwitch,
          leading: const Icon(AbiliaIcons.handiAlarm),
          value: settings.alarm,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectAlarm: v)),
          child: Text(t.selectAlarm),
        ),
        SwitchField(
          key: TestKey.addActivitySelectReminderSwitch,
          leading: const Icon(AbiliaIcons.handiReminder),
          value: settings.reminders,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectReminder: v)),
          child: Text(t.selectReminder),
        ),
        SwitchField(
          key: TestKey.addActivitySelectChecklistSwitch,
          leading: const Icon(AbiliaIcons.radioCheckboxUnselected),
          value: settings.checklist,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectChecklist: v)),
          child: Text(t.selectChecklist),
        ),
        SwitchField(
          key: TestKey.addActivitySelectNoteSwitch,
          leading: const Icon(AbiliaIcons.note),
          value: settings.notes,
          onChanged: (v) => context
              .read<AddActivitySettingsCubit>()
              .stepByStepSetting(settings.copyWith(selectNote: v)),
          child: Text(t.selectNote),
        ),
      ]
          .map((c) => Padding(
              padding: EdgeInsets.only(
                bottom: layout.formPadding.verticalItemDistance,
              ),
              child: c))
          .toList(),
    );
  }

  bool _checkRequiredStates(StepByStepSettings settings) =>
      [
        settings.title,
        settings.image,
        settings.template,
      ].where((checked) => checked).length >
      1;
}
