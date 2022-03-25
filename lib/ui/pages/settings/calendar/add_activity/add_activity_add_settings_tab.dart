import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityAddSettingsTab extends StatelessWidget {
  const AddActivityAddSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
        builder: (context, state) {
      final addTabState = state.editActivitySettings;
      final stepState = state.stepByStepSettingsState;
      onModeChanged(mode) =>
          context.read<AddActivitySettingsCubit>().changeAddActivitySettings(
                state.copyWith(newActivityMode: mode),
              );
      onTabStateChanged(EditActivitySettings editSettings) =>
          context.read<AddActivitySettingsCubit>().changeAddActivitySettings(
              state.copyWith(editActivitySettings: editSettings));
      onStepChanged(WizardStepsSettings wizardSettings) =>
          context.read<AddActivitySettingsCubit>().changeAddActivitySettings(
              state.copyWith(stepByStepSettingsState: wizardSettings));

      return SettingsTab(
        children: [
          Tts(child: Text(t.add)),
          RadioField(
            value: NewActivityMode.editView,
            groupValue: state.newActivityMode,
            onChanged: onModeChanged,
            text: Text(t.throughEditView),
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
          ),
          RadioField(
            value: NewActivityMode.stepByStep,
            groupValue: state.newActivityMode,
            onChanged: onModeChanged,
            text: Text(t.stepByStep),
            leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
          ),
          const Divider(),
          if (state.newActivityMode == NewActivityMode.editView) ...[
            SwitchField(
              leading: const Icon(AbiliaIcons.month),
              value: addTabState.date,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(date: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.sendAndReceive),
              value: addTabState.type,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(type: v)),
              child: Text(t.selectType),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.basicActivity),
              value: addTabState.template,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(template: v)),
              child: Text(t.showBasicActivities),
            ),
          ] else ...[
            SwitchField(
              leading: const Icon(AbiliaIcons.basicActivity),
              value: stepState.template,
              onChanged: (v) {
                if (_checkRequiredStates(stepState, v)) {
                  onStepChanged(stepState.copyWith(showBasicActivities: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.showBasicActivities),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.selectTextSize),
              value: stepState.title,
              onChanged: (v) {
                if (_checkRequiredStates(stepState, v)) {
                  onStepChanged(stepState.copyWith(selectName: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.selectName),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.myPhotos),
              value: stepState.image,
              onChanged: (v) {
                if (_checkRequiredStates(stepState, v)) {
                  onStepChanged(stepState.copyWith(selectImage: v));
                } else {
                  _showErrorDialog(context);
                }
              },
              child: Text(t.selectImage),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.month),
              value: stepState.datePicker,
              onChanged: (v) => onStepChanged(stepState.copyWith(setDate: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.sendAndReceive),
              value: stepState.type,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectType: v)),
              child: Text(t.selectType),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiCheck),
              value: stepState.checkable,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectCheckable: v)),
              child: Text(t.selectCheckable),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.passwordProtection),
              value: stepState.availability,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAvailableFor: v)),
              child: Text(t.selectAvailableFor),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.deleteAllClear),
              value: stepState.removeAfter,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectDeleteAfter: v)),
              child: Text(t.selectDeleteAfter),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiAlarm),
              value: stepState.alarm,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAlarm: v)),
              child: Text(t.selectAlarm),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.radiocheckboxUnselected),
              value: stepState.checklist,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectChecklist: v)),
              child: Text(t.selectChecklist),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.note),
              value: stepState.notes,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectNote: v)),
              child: Text(t.selectNote),
            ),
            SwitchField(
              leading: const Icon(AbiliaIcons.handiReminder),
              value: stepState.reminders,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectReminder: v)),
              child: Text(t.selectReminder),
            ),
          ]
        ],
      );
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        text: Translator.of(context).translate.missingRequiredActivitySetting,
      ),
    );
  }

  bool _checkRequiredStates(WizardStepsSettings stepState, bool value) {
    if (value) {
      return true;
    }
    var numberOfChecked = [
      stepState.title,
      stepState.image,
      stepState.template,
    ].where((checked) => checked).length;
    return numberOfChecked > 1;
  }
}
