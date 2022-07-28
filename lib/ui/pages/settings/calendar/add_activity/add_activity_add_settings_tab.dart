import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityAddSettingsTab extends StatelessWidget {
  const AddActivityAddSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocSelector<AddActivitySettingsCubit, AddActivitySettingsState,
        NewActivityMode>(
      selector: (state) => state.newActivityMode,
      builder: (context, newActivityMode) => SettingsTab(
        children: [
          Tts(child: Text(t.add)),
          RadioField(
            value: NewActivityMode.editView,
            groupValue: newActivityMode,
            onChanged: context.read<AddActivitySettingsCubit>().newActivityMode,
            text: Text(t.throughEditView),
            leading: const Icon(AbiliaIcons.editView),
          ),
          RadioField(
            value: NewActivityMode.stepByStep,
            groupValue: newActivityMode,
            onChanged: context.read<AddActivitySettingsCubit>().newActivityMode,
            text: Text(t.stepByStep),
            leading: const Icon(AbiliaIcons.stepByStep),
          ),
          const Divider(),
          if (newActivityMode == NewActivityMode.editView)
            const _EditActivitySettingsWidget()
          else
            const _StepByStepSettingsWidget(),
        ],
      ),
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
    return BlocSelector<AddActivitySettingsCubit, AddActivitySettingsState,
        EditActivitySettings>(
      selector: (state) => state.editActivitySetting,
      builder: (context, addTabState) {
        return Column(
          children: [
            SwitchField(
              leading: const Icon(AbiliaIcons.basicActivity),
              value: addTabState.template,
              onChanged: (v) {
                if (v || _checkRequiredStates(addTabState)) {
                  context
                      .read<AddActivitySettingsCubit>()
                      .editSettings(addTabState.copyWith(template: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.showTemplates),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.selectTextSize),
              value: addTabState.title,
              onChanged: (v) {
                if (v || _checkRequiredStates(addTabState)) {
                  context
                      .read<AddActivitySettingsCubit>()
                      .editSettings(addTabState.copyWith(title: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.selectName),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.myPhotos),
              value: addTabState.image,
              onChanged: (v) {
                if (v || _checkRequiredStates(addTabState)) {
                  context
                      .read<AddActivitySettingsCubit>()
                      .editSettings(addTabState.copyWith(image: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.selectImage),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.month),
              value: addTabState.date,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(addTabState.copyWith(date: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiCheck),
              value: addTabState.checkable,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(addTabState.copyWith(checkable: v)),
              child: Text(t.selectCheckable),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.deleteAllClear),
              value: addTabState.removeAfter,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(addTabState.copyWith(removeAfter: v)),
              child: Text(t.deleteAfter),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.passwordProtection),
              value: addTabState.availability,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .editSettings(addTabState.copyWith(availability: v)),
              child: Text(t.selectAvailableFor),
            ),
          ]
              .map((c) => Padding(
                  padding: EdgeInsets.only(
                    bottom: layout.formPadding.verticalItemDistance,
                  ),
                  child: c))
              .toList(),
        );
      },
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
    return BlocSelector<AddActivitySettingsCubit, AddActivitySettingsState,
        StepByStepSettings>(
      selector: (state) => state.stepByStepSetting,
      builder: (context, settings) {
        return Column(
          children: [
            SwitchField(
              leading: const Icon(AbiliaIcons.basicActivity),
              value: settings.template,
              onChanged: (v) {
                if (v || _checkRequiredStates(settings)) {
                  context.read<AddActivitySettingsCubit>().stepByStepSetting(
                      settings.copyWith(showBasicActivities: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.showTemplates),
            ),
            SwitchField(
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
              leading: const Icon(AbiliaIcons.month),
              value: settings.datePicker,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(setDate: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.sendAndReceive),
              value: settings.type,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectType: v)),
              child: Text(t.selectType),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiCheck),
              value: settings.checkable,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectCheckable: v)),
              child: Text(t.selectCheckable),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.deleteAllClear),
              value: settings.removeAfter,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectDeleteAfter: v)),
              child: Text(t.deleteAfter),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.passwordProtection),
              value: settings.availability,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectAvailableFor: v)),
              child: Text(t.selectAvailableFor),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiAlarm),
              value: settings.alarm,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectAlarm: v)),
              child: Text(t.selectAlarm),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiReminder),
              value: settings.reminders,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectReminder: v)),
              child: Text(t.selectReminder),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.radiocheckboxUnselected),
              value: settings.checklist,
              onChanged: (v) => context
                  .read<AddActivitySettingsCubit>()
                  .stepByStepSetting(settings.copyWith(selectChecklist: v)),
              child: Text(t.selectChecklist),
            ),
            SwitchField(
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
      },
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
