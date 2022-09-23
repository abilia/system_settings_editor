import 'package:equatable/equatable.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/all.dart';

class ActivityViewSettings extends Equatable {
  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft;

  const ActivityViewSettings({
    this.displayAlarmButton = true,
    this.displayDeleteButton = true,
    this.displayEditButton = true,
    this.displayQuarterHour = true,
    this.displayTimeLeft = true,
  });

  static const String displayAlarmButtonKey =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButtonKey =
          'activity_detailed_setting_display_delete_button',
      displayEditButtonKey = 'activity_detailed_setting_display_edit_button',
      displayQuarterHourKey = 'activity_detailed_setting_display_qhw',
      displayTimeLeftKey = 'activity_detailed_setting_display_qhw_time_left';

  factory ActivityViewSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      ActivityViewSettings(
        displayAlarmButton: settings.getBool(
          displayAlarmButtonKey,
        ),
        displayDeleteButton: settings.getBool(
          displayDeleteButtonKey,
        ),
        displayEditButton: settings.getBool(
          displayEditButtonKey,
        ),
        displayQuarterHour: settings.getBool(
          displayQuarterHourKey,
        ),
        displayTimeLeft: settings.getBool(
          displayTimeLeftKey,
        ),
      );

  ActivityViewSettings copyWith({
    bool? displayAlarmButton,
    bool? displayDeleteButton,
    bool? displayEditButton,
    bool? displayQuarterHour,
    bool? displayTimeLeft,
  }) =>
      ActivityViewSettings(
        displayAlarmButton: displayAlarmButton ?? this.displayAlarmButton,
        displayDeleteButton: displayDeleteButton ?? this.displayDeleteButton,
        displayEditButton: displayEditButton ?? this.displayEditButton,
        displayQuarterHour: displayQuarterHour ?? this.displayQuarterHour,
        displayTimeLeft: displayTimeLeft ?? this.displayTimeLeft,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: displayAlarmButton,
          identifier: ActivityViewSettings.displayAlarmButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayDeleteButton,
          identifier: ActivityViewSettings.displayDeleteButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayEditButton,
          identifier: ActivityViewSettings.displayEditButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayQuarterHour,
          identifier: ActivityViewSettings.displayQuarterHourKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayTimeLeft,
          identifier: ActivityViewSettings.displayTimeLeftKey,
        ),
      ];


  @override
  List<Object?> get props => [
        displayAlarmButton,
        displayDeleteButton,
        displayEditButton,
        displayQuarterHour,
        displayTimeLeft,
      ];
}
