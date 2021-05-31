// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityAddSettingsTab extends StatelessWidget {
  const AddActivityAddSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<AddActivitySettingsCubit, AddActivitySettingsState>(
        builder: (context, state) {
      final addTabState = state.addTabEditViewSettingsState;
      final stepState = state.stepByStepSettingsState;
      final onModeChanged = (v) =>
          context.read<AddActivitySettingsCubit>().changeAddActivitySettings(
                state.copyWith(
                  addTabEditViewSettingsState:
                      addTabState.copyWith(newActivityMode: v),
                ),
              );
      final onTabStateChanged = (AddTabEditViewSettingsState tss) => context
          .read<AddActivitySettingsCubit>()
          .changeAddActivitySettings(
              state.copyWith(addTabEditViewSettingsState: tss));
      final onStepChanged = (StepByStepSettingsState sss) => context
          .read<AddActivitySettingsCubit>()
          .changeAddActivitySettings(
              state.copyWith(stepByStepSettingsState: sss));
      return SettingsTab(
        children: [
          Tts(child: Text(t.add)),
          RadioField(
            value: NewActivityMode.editView,
            groupValue: addTabState.newActivityMode,
            onChanged: onModeChanged,
            text: Text(t.throughEditView),
            leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          ),
          RadioField(
            value: NewActivityMode.stepByStep,
            groupValue: addTabState.newActivityMode,
            onChanged: onModeChanged,
            text: Text(t.stepByStep),
            leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          ),
          Divider(),
          if (addTabState.newActivityMode == NewActivityMode.editView) ...[
            SwitchField(
              leading: Icon(AbiliaIcons.month),
              value: addTabState.selectDate,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(selectDate: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.send_and_receive),
              value: addTabState.selectType,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(selectType: v)),
              child: Text(t.selectType),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.basic_activity),
              value: addTabState.showBasicActivities,
              onChanged: (v) => onTabStateChanged(
                  addTabState.copyWith(showBasicActivities: v)),
              child: Text(t.showBasicActivities),
            ),
          ] else ...[
            SwitchField(
              leading: Icon(AbiliaIcons.basic_activity),
              value: stepState.showBasicActivities,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(showBasicActivities: v)),
              child: Text(t.showBasicActivities),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.select_text_size),
              value: stepState.selectName,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectName: v)),
              child: Text(t.selectName),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.my_photos),
              value: stepState.selectImage,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectImage: v)),
              child: Text(t.selectImage),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.month),
              value: stepState.setDate,
              onChanged: (v) => onStepChanged(stepState.copyWith(setDate: v)),
              child: Text(t.selectDate),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.send_and_receive),
              value: stepState.selectType,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectType: v)),
              child: Text(t.selectType),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.handi_check),
              value: stepState.selectCheckable,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectCheckable: v)),
              child: Text(t.selectCheckable),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.password_protection),
              value: stepState.selectAvailableFor,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAvailableFor: v)),
              child: Text(t.selectAvailableFor),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.delete_all_clear),
              value: stepState.selectDeleteAfter,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectDeleteAfter: v)),
              child: Text(t.selectDeleteAfter),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.handi_alarm),
              value: stepState.selectAlarm,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAlarm: v)),
              child: Text(t.selectAlarm),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.radiocheckbox_unselected),
              value: stepState.selectChecklist,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectChecklist: v)),
              child: Text(t.selectChecklist),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.note),
              value: stepState.selectNote,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectNote: v)),
              child: Text(t.selectNote),
            ),
            SwitchField(
              leading: Icon(AbiliaIcons.handi_reminder),
              value: stepState.selectReminder,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectReminder: v)),
              child: Text(t.selectReminder),
            ),
          ]
        ],
      );
    });
  }
}
