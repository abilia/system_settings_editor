import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class EditActivitySettings extends Equatable {
  static const templateKey = 'advanced_activity_template',
      titleKey = 'advanced_activity_title',
      imageKey = 'advanced_activity_image',
      dateKey = 'advanced_activity_date',
      fullDayKey = 'advanced_activity_full_day',
      checkableKey = 'advanced_activity_checkable',
      availabilityKey = 'advanced_activity_availability',
      removeAfterKey = 'advanced_activity_remove_after',
      alarmKey = 'advanced_activity_alarm',
      checklistKey = 'advanced_activity_checklist',
      notesKey = 'advanced_activity_notes',
      remindersKey = 'advanced_activity_reminders';

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

  const EditActivitySettings({
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

  factory EditActivitySettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      EditActivitySettings(
        template: settings.getBool(templateKey),
        title: settings.getBool(titleKey),
        image: settings.getBool(imageKey),
        date: settings.getBool(dateKey),
        fullDay: settings.getBool(fullDayKey),
        checkable: settings.getBool(checkableKey),
        availability: settings.getBool(availabilityKey),
        removeAfter: settings.getBool(removeAfterKey),
        alarm: settings.getBool(alarmKey),
        checklist: settings.getBool(checklistKey),
        notes: settings.getBool(notesKey),
        reminders: settings.getBool(remindersKey),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
            data: template, identifier: templateKey),
        MemoplannerSettingData.fromData(data: title, identifier: titleKey),
        MemoplannerSettingData.fromData(data: image, identifier: imageKey),
        MemoplannerSettingData.fromData(data: date, identifier: dateKey),
        MemoplannerSettingData.fromData(data: fullDay, identifier: fullDayKey),
        MemoplannerSettingData.fromData(
            data: checkable, identifier: checkableKey),
        MemoplannerSettingData.fromData(
            data: availability, identifier: availabilityKey),
        MemoplannerSettingData.fromData(
            data: removeAfter, identifier: removeAfterKey),
        MemoplannerSettingData.fromData(data: alarm, identifier: alarmKey),
        MemoplannerSettingData.fromData(
            data: checklist, identifier: checklistKey),
        MemoplannerSettingData.fromData(data: notes, identifier: notesKey),
        MemoplannerSettingData.fromData(
            data: reminders, identifier: remindersKey),
      ];

  EditActivitySettings copyWith({
    bool? template,
    bool? title,
    bool? image,
    bool? date,
    bool? fullDay,
    bool? type,
    bool? checkable,
    bool? availability,
    bool? removeAfter,
    bool? alarm,
    bool? checklist,
    bool? notes,
    bool? reminders,
  }) =>
      EditActivitySettings(
        template: template ?? this.template,
        title: title ?? this.title,
        image: image ?? this.image,
        date: date ?? this.date,
        fullDay: fullDay ?? this.fullDay,
        checkable: checkable ?? this.checkable,
        availability: availability ?? this.availability,
        removeAfter: removeAfter ?? this.removeAfter,
        alarm: alarm ?? this.alarm,
        checklist: checklist ?? this.checklist,
        notes: notes ?? this.notes,
        reminders: reminders ?? this.reminders,
      );

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
