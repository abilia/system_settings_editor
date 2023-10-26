import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

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
          Map<String, GenericSettingData> settings) =>
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
        MemoplannerSettingData(
          data: displayAlarmButton,
          identifier: ActivityViewSettings.displayAlarmButtonKey,
        ),
        MemoplannerSettingData(
          data: displayDeleteButton,
          identifier: ActivityViewSettings.displayDeleteButtonKey,
        ),
        MemoplannerSettingData(
          data: displayEditButton,
          identifier: ActivityViewSettings.displayEditButtonKey,
        ),
        MemoplannerSettingData(
          data: displayQuarterHour,
          identifier: ActivityViewSettings.displayQuarterHourKey,
        ),
        MemoplannerSettingData(
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
