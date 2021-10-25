import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class WizardStepsSettings extends Equatable {
  static const wizardTemplateStepKey = 'wizard_template_step',
      wizardTitleStepKey = 'wizard_title_step',
      wizardImageStepKey = 'wizard_image_step',
      wizardDatePickerStepKey = 'wizard_date_picker_step',
      wizardTypeStepKey = 'wizard_type_step',
      wizardCheckableStepKey = 'wizard_checkable_step',
      wizardAvailabilityTypeKey = 'wizard_availability_type',
      wizardRemoveAfterStepKey = 'wizard_remove_after_step',
      wizardAlarmStepKey = 'wizard_alarm_step',
      wizardChecklistStepKey = 'wizard_checklist_step',
      wizardNotesStepKey = 'wizard_notes_step',
      wizardRemindersStepKey = 'wizard_reminders_step';

  static const keys = [
    wizardTemplateStepKey,
    wizardTitleStepKey,
    wizardImageStepKey,
    wizardDatePickerStepKey,
    wizardTypeStepKey,
    wizardCheckableStepKey,
    wizardAvailabilityTypeKey,
    wizardRemoveAfterStepKey,
    wizardAlarmStepKey,
    wizardChecklistStepKey,
    wizardNotesStepKey,
    wizardRemindersStepKey,
  ];

  final bool template,
      title,
      image,
      datePicker,
      type,
      checkable,
      availability,
      removeAfter,
      alarm,
      checklist,
      notes,
      reminders;

  const WizardStepsSettings({
    this.template = true,
    this.title = true,
    this.image = true,
    this.datePicker = true,
    this.type = false,
    this.checkable = true,
    this.availability = true,
    this.removeAfter = false,
    this.alarm = false,
    this.checklist = false,
    this.notes = false,
    this.reminders = false,
  });

  bool get onlyTemplateStep => template && !title && !image;

  factory WizardStepsSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      WizardStepsSettings(
        template: settings.getBool(
          wizardTemplateStepKey,
        ),
        title: settings.getBool(
          wizardTitleStepKey,
        ),
        image: settings.getBool(
          wizardImageStepKey,
        ),
        datePicker: settings.getBool(
          wizardDatePickerStepKey,
        ),
        type: settings.getBool(
          wizardTypeStepKey,
          defaultValue: false,
        ),
        checkable: settings.getBool(
          wizardCheckableStepKey,
        ),
        availability: settings.getBool(
          wizardAvailabilityTypeKey,
        ),
        removeAfter: settings.getBool(
          wizardRemoveAfterStepKey,
          defaultValue: false,
        ),
        alarm: settings.getBool(
          wizardAlarmStepKey,
          defaultValue: false,
        ),
        checklist: settings.getBool(
          wizardChecklistStepKey,
          defaultValue: false,
        ),
        notes: settings.getBool(
          wizardNotesStepKey,
          defaultValue: false,
        ),
        reminders: settings.getBool(
          wizardRemindersStepKey,
          defaultValue: false,
        ),
      );

  @override
  List<Object?> get props => [
        template,
        title,
        image,
        datePicker,
        type,
        checkable,
        availability,
        removeAfter,
        alarm,
        checklist,
        notes,
        reminders,
      ];
}
