import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class StepByStepSettings extends Equatable {
  static const templateKey = 'wizard_template_step',
      titleKey = 'wizard_title_step',
      imageKey = 'wizard_image_step',
      dateKey = 'wizard_date_picker_step',
      typeKey = 'wizard_type_step',
      checkableKey = 'wizard_checkable_step',
      availabilityKey = 'wizard_availability_type',
      removeAfterKey = 'wizard_remove_after_step',
      alarmKey = 'wizard_alarm_step',
      checklistKey = 'wizard_checklist_step',
      notesKey = 'wizard_notes_step',
      remindersKey = 'wizard_reminders_step';

  final bool template,
      title,
      image,
      time,
      datePicker,
      type,
      checkable,
      availability,
      removeAfter,
      alarm,
      checklist,
      notes,
      reminders;

  const StepByStepSettings({
    this.template = true,
    this.title = true,
    this.image = true,
    this.time = true,
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

  StepByStepSettings copyWith({
    bool? showBasicActivities,
    bool? selectName,
    bool? selectImage,
    bool? setDate,
    bool? selectType,
    bool? selectCheckable,
    bool? selectAvailableFor,
    bool? selectDeleteAfter,
    bool? selectAlarm,
    bool? selectChecklist,
    bool? selectNote,
    bool? selectReminder,
  }) =>
      StepByStepSettings(
        template: showBasicActivities ?? template,
        title: selectName ?? title,
        image: selectImage ?? image,
        datePicker: setDate ?? datePicker,
        type: selectType ?? type,
        checkable: selectCheckable ?? checkable,
        availability: selectAvailableFor ?? availability,
        removeAfter: selectDeleteAfter ?? removeAfter,
        alarm: selectAlarm ?? alarm,
        checklist: selectChecklist ?? checklist,
        notes: selectNote ?? notes,
        reminders: selectReminder ?? reminders,
      );

  factory StepByStepSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      StepByStepSettings(
        template: settings.getBool(
          templateKey,
        ),
        title: settings.getBool(
          titleKey,
        ),
        image: settings.getBool(
          imageKey,
        ),
        datePicker: settings.getBool(
          dateKey,
        ),
        type: settings.getBool(
          typeKey,
          defaultValue: false,
        ),
        checkable: settings.getBool(
          checkableKey,
        ),
        availability: settings.getBool(
          availabilityKey,
        ),
        removeAfter: settings.getBool(
          removeAfterKey,
          defaultValue: false,
        ),
        alarm: settings.getBool(
          alarmKey,
          defaultValue: false,
        ),
        checklist: settings.getBool(
          checklistKey,
          defaultValue: false,
        ),
        notes: settings.getBool(
          notesKey,
          defaultValue: false,
        ),
        reminders: settings.getBool(
          remindersKey,
          defaultValue: false,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: template,
          identifier: templateKey,
        ),
        MemoplannerSettingData.fromData(data: title, identifier: titleKey),
        MemoplannerSettingData.fromData(data: image, identifier: imageKey),
        MemoplannerSettingData.fromData(data: datePicker, identifier: dateKey),
        MemoplannerSettingData.fromData(data: type, identifier: typeKey),
        MemoplannerSettingData.fromData(
          data: checkable,
          identifier: checkableKey,
        ),
        MemoplannerSettingData.fromData(
          data: availability,
          identifier: availabilityKey,
        ),
        MemoplannerSettingData.fromData(
          data: removeAfter,
          identifier: removeAfterKey,
        ),
        MemoplannerSettingData.fromData(
          data: alarm,
          identifier: alarmKey,
        ),
        MemoplannerSettingData.fromData(
          data: checklist,
          identifier: checklistKey,
        ),
        MemoplannerSettingData.fromData(data: notes, identifier: notesKey),
        MemoplannerSettingData.fromData(
          data: reminders,
          identifier: remindersKey,
        ),
      ];

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
        time,
      ];
}
