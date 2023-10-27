import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class StepByStepSettings extends Equatable {
  static const templateKey = 'wizard_template_step',
      titleKey = 'wizard_title_step',
      imageKey = 'wizard_image_step',
      dateKey = 'wizard_date_picker_step',
      fullDayKey = 'wizard_type_step',
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
      date,
      fullDay,
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
    this.date = true,
    this.fullDay = true,
    this.checkable = true,
    this.availability = true,
    this.removeAfter = true,
    this.alarm = true,
    this.checklist = true,
    this.notes = true,
    this.reminders = true,
  });

  StepByStepSettings copyWith({
    bool? showBasicActivities,
    bool? selectName,
    bool? selectImage,
    bool? setDate,
    bool? showFullDay,
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
        date: setDate ?? date,
        fullDay: showFullDay ?? fullDay,
        checkable: selectCheckable ?? checkable,
        availability: selectAvailableFor ?? availability,
        removeAfter: selectDeleteAfter ?? removeAfter,
        alarm: selectAlarm ?? alarm,
        checklist: selectChecklist ?? checklist,
        notes: selectNote ?? notes,
        reminders: selectReminder ?? reminders,
      );

  factory StepByStepSettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
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
        date: settings.getBool(
          dateKey,
        ),
        fullDay: settings.getBool(
          fullDayKey,
        ),
        checkable: settings.getBool(
          checkableKey,
        ),
        availability: settings.getBool(
          availabilityKey,
        ),
        removeAfter: settings.getBool(
          removeAfterKey,
        ),
        alarm: settings.getBool(
          alarmKey,
        ),
        checklist: settings.getBool(
          checklistKey,
        ),
        notes: settings.getBool(
          notesKey,
        ),
        reminders: settings.getBool(
          remindersKey,
        ),
      );

  List<GenericSettingData> get memoplannerSettingData => [
        MemoplannerSettingData(data: template, identifier: templateKey),
        MemoplannerSettingData(data: title, identifier: titleKey),
        MemoplannerSettingData(data: image, identifier: imageKey),
        MemoplannerSettingData(data: date, identifier: dateKey),
        MemoplannerSettingData(data: fullDay, identifier: fullDayKey),
        MemoplannerSettingData(data: checkable, identifier: checkableKey),
        MemoplannerSettingData(data: availability, identifier: availabilityKey),
        MemoplannerSettingData(data: removeAfter, identifier: removeAfterKey),
        MemoplannerSettingData(data: alarm, identifier: alarmKey),
        MemoplannerSettingData(data: checklist, identifier: checklistKey),
        MemoplannerSettingData(data: notes, identifier: notesKey),
        MemoplannerSettingData(data: reminders, identifier: remindersKey),
      ];

  @override
  List<Object?> get props => [
        template,
        title,
        image,
        date,
        fullDay,
        checkable,
        availability,
        removeAfter,
        alarm,
        checklist,
        notes,
        reminders,
      ];
}
