import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class GeneralAddActivitySettings extends Equatable {
  static const allowPassedStartTimeKey = 'add_activity_time_before_current',
      addRecurringActivityKey = 'add_activity_recurring_step',
      showEndTimeKey = 'add_activity_end_time',
      showAlarmKey = 'add_activity_display_alarm',
      showVibrationAlarmKey = 'add_activity_display_vibration_alarm',
      showSilentAlarmKey = 'add_activity_display_silent_alarm',
      showNoAlarmKey = 'add_activity_display_no_alarm',
      showAlarmOnlyAtStartKey = 'add_activity_display_alarm_only_at_start',
      showSpeechAtAlarmKey = 'add_activity_display_speech_at_alarm';

  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showVibrationAlarm,
      showSilentAlarm,
      showNoAlarm,
      showAlarmOnlyAtStart,
      showSpeechAtAlarm;

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        showAlarm,
        showVibrationAlarm,
        showSilentAlarm,
        showNoAlarm,
      ].where((e) => e).length >=
      2;

  const GeneralAddActivitySettings({
    this.allowPassedStartTime = true,
    this.addRecurringActivity = true,
    this.showEndTime = true,
    this.showAlarm = true,
    this.showVibrationAlarm = true,
    this.showSilentAlarm = true,
    this.showNoAlarm = true,
    this.showAlarmOnlyAtStart = true,
    this.showSpeechAtAlarm = true,
  });

  GeneralAddActivitySettings copyWith({
    bool? allowPassedStartTime,
    bool? addRecurringActivity,
    bool? showEndTime,
    bool? showAlarm,
    bool? showVibrationAlarm,
    bool? showSilentAlarm,
    bool? showNoAlarm,
    bool? showAlarmOnlyAtStart,
    bool? showSpeechAtAlarm,
    bool? showSelectEndDate,
  }) =>
      GeneralAddActivitySettings(
        allowPassedStartTime: allowPassedStartTime ?? this.allowPassedStartTime,
        addRecurringActivity: addRecurringActivity ?? this.addRecurringActivity,
        showEndTime: showEndTime ?? this.showEndTime,
        showAlarm: showAlarm ?? this.showAlarm,
        showVibrationAlarm: showVibrationAlarm ?? this.showVibrationAlarm,
        showSilentAlarm: showSilentAlarm ?? this.showSilentAlarm,
        showNoAlarm: showNoAlarm ?? this.showNoAlarm,
        showAlarmOnlyAtStart: showAlarmOnlyAtStart ?? this.showAlarmOnlyAtStart,
        showSpeechAtAlarm: showSpeechAtAlarm ?? this.showSpeechAtAlarm,
      );

  factory GeneralAddActivitySettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      GeneralAddActivitySettings(
        allowPassedStartTime: settings.getBool(allowPassedStartTimeKey),
        addRecurringActivity: settings.getBool(addRecurringActivityKey),
        showEndTime: settings.getBool(showEndTimeKey),
        showAlarm: settings.getBool(showAlarmKey),
        showVibrationAlarm: settings.getBool(showVibrationAlarmKey),
        showSilentAlarm: settings.getBool(showSilentAlarmKey),
        showNoAlarm: settings.getBool(showNoAlarmKey),
        showAlarmOnlyAtStart: settings.getBool(showAlarmOnlyAtStartKey),
        showSpeechAtAlarm: settings.getBool(showSpeechAtAlarmKey),
      );

  List<GenericSettingData> get memoplannerSettingData => [
        GenericSettingData.fromData(
            data: allowPassedStartTime, identifier: allowPassedStartTimeKey),
        GenericSettingData.fromData(
            data: addRecurringActivity, identifier: addRecurringActivityKey),
        GenericSettingData.fromData(
            data: showEndTime, identifier: showEndTimeKey),
        GenericSettingData.fromData(data: showAlarm, identifier: showAlarmKey),
        GenericSettingData.fromData(
            data: showVibrationAlarm, identifier: showVibrationAlarmKey),
        GenericSettingData.fromData(
            data: showSilentAlarm, identifier: showSilentAlarmKey),
        GenericSettingData.fromData(
            data: showNoAlarm, identifier: showNoAlarmKey),
        GenericSettingData.fromData(
            data: showAlarmOnlyAtStart, identifier: showAlarmOnlyAtStartKey),
        GenericSettingData.fromData(
            data: showSpeechAtAlarm, identifier: showSpeechAtAlarmKey),
      ];

  @override
  List<Object?> get props => [
        allowPassedStartTime,
        addRecurringActivity,
        showEndTime,
        showAlarm,
        showVibrationAlarm,
        showSilentAlarm,
        showNoAlarm,
        showAlarmOnlyAtStart,
        showSpeechAtAlarm,
      ];
}
