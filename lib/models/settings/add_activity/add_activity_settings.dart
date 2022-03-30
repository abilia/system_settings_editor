import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class AddActivitySettings extends Equatable {
  static const allowPassedStartTimeKey = 'add_activity_time_before_current',
      addRecurringActivityKey = 'add_activity_recurring_step',
      showEndTimeKey = 'add_activity_end_time',
      showAlarmKey = 'add_activity_display_alarm',
      showSilentAlarmKey = 'add_activity_display_silent_alarm',
      showNoAlarmKey = 'add_activity_display_no_alarm';

  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showSilentAlarm,
      showNoAlarm;

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        showAlarm,
        showSilentAlarm, // for Vibration
        showSilentAlarm, // and Silent
        showNoAlarm,
      ].where((e) => e).length >=
      2;

  const AddActivitySettings({
    this.allowPassedStartTime = true,
    this.addRecurringActivity = true,
    this.showEndTime = true,
    this.showAlarm = true,
    this.showSilentAlarm = true,
    this.showNoAlarm = true,
  });

  AddActivitySettings copyWith({
    bool? allowPassedStartTime,
    bool? addRecurringActivity,
    bool? showEndTime,
    bool? showAlarm,
    bool? showSilentAlarm,
    bool? showNoAlarm,
  }) =>
      AddActivitySettings(
        allowPassedStartTime: allowPassedStartTime ?? this.allowPassedStartTime,
        addRecurringActivity: addRecurringActivity ?? this.addRecurringActivity,
        showEndTime: showEndTime ?? this.showEndTime,
        showAlarm: showAlarm ?? this.showAlarm,
        showSilentAlarm: showSilentAlarm ?? this.showSilentAlarm,
        showNoAlarm: showNoAlarm ?? this.showNoAlarm,
      );

  factory AddActivitySettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      AddActivitySettings(
        allowPassedStartTime: settings.getBool(allowPassedStartTimeKey),
        addRecurringActivity: settings.getBool(addRecurringActivityKey),
        showEndTime: settings.getBool(showEndTimeKey),
        showAlarm: settings.getBool(showAlarmKey),
        showSilentAlarm: settings.getBool(showSilentAlarmKey),
        showNoAlarm: settings.getBool(showNoAlarmKey),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
            data: allowPassedStartTime, identifier: allowPassedStartTimeKey),
        MemoplannerSettingData.fromData(
            data: addRecurringActivity, identifier: addRecurringActivityKey),
        MemoplannerSettingData.fromData(
            data: showEndTime, identifier: showEndTimeKey),
        MemoplannerSettingData.fromData(
            data: showAlarm, identifier: showAlarmKey),
        MemoplannerSettingData.fromData(
            data: showSilentAlarm, identifier: showSilentAlarmKey),
        MemoplannerSettingData.fromData(
            data: showNoAlarm, identifier: showNoAlarmKey),
      ];

  @override
  List<Object?> get props => [
        allowPassedStartTime,
        addRecurringActivity,
        showEndTime,
        showAlarm,
        showSilentAlarm,
        showNoAlarm,
      ];
}
