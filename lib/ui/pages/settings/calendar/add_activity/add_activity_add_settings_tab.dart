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
              text: Text(t.selectDate),
              leading: Icon(AbiliaIcons.month),
              value: addTabState.selectDate,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(selectDate: v)),
            ),
            SwitchField(
              text: Text(t.selectType),
              leading: Icon(AbiliaIcons.send_and_receive),
              value: addTabState.selectType,
              onChanged: (v) =>
                  onTabStateChanged(addTabState.copyWith(selectType: v)),
            ),
            SwitchField(
              text: Text(t.showBasicActivities),
              leading: Icon(AbiliaIcons.basic_activity),
              value: addTabState.showBasicActivities,
              onChanged: (v) => onTabStateChanged(
                  addTabState.copyWith(showBasicActivities: v)),
            ),
          ] else ...[
            SwitchField(
              text: Text(t.showBasicActivities),
              leading: Icon(AbiliaIcons.basic_activity),
              value: stepState.showBasicActivities,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(showBasicActivities: v)),
            ),
            SwitchField(
              text: Text(t.selectName),
              leading: Icon(AbiliaIcons.select_text_size),
              value: stepState.selectName,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectName: v)),
            ),
            SwitchField(
              text: Text(t.selectImage),
              leading: Icon(AbiliaIcons.my_photos),
              value: stepState.selectImage,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectImage: v)),
            ),
            SwitchField(
              text: Text(t.selectDate),
              leading: Icon(AbiliaIcons.month),
              value: stepState.setDate,
              onChanged: (v) => onStepChanged(stepState.copyWith(setDate: v)),
            ),
            SwitchField(
              text: Text(t.selectType),
              leading: Icon(AbiliaIcons.send_and_receive),
              value: stepState.selectType,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectType: v)),
            ),
            SwitchField(
              text: Text(t.selectCheckable),
              leading: Icon(AbiliaIcons.handi_check),
              value: stepState.selectCheckable,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectCheckable: v)),
            ),
            SwitchField(
              text: Text(t.selectAvailableFor),
              leading: Icon(AbiliaIcons.password_protection),
              value: stepState.selectAvailableFor,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAvailableFor: v)),
            ),
            SwitchField(
              text: Text(t.selectDeleteAfter),
              leading: Icon(AbiliaIcons.delete_all_clear),
              value: stepState.selectDeleteAfter,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectDeleteAfter: v)),
            ),
            SwitchField(
              text: Text(t.selectAlarm),
              leading: Icon(AbiliaIcons.handi_alarm),
              value: stepState.selectAlarm,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectAlarm: v)),
            ),
            SwitchField(
              text: Text(t.selectChecklist),
              leading: Icon(AbiliaIcons.radiocheckbox_unselected),
              value: stepState.selectChecklist,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectChecklist: v)),
            ),
            SwitchField(
              text: Text(t.selectNote),
              leading: Icon(AbiliaIcons.note),
              value: stepState.selectNote,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectNote: v)),
            ),
            SwitchField(
              text: Text(t.selectReminder),
              leading: Icon(AbiliaIcons.handi_reminder),
              value: stepState.selectReminder,
              onChanged: (v) =>
                  onStepChanged(stepState.copyWith(selectReminder: v)),
            ),
          ]
        ],
      );
    });
  }
}
