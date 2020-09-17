part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsState {
  final MemoplannerSettings settings;
  const MemoplannerSettingsState(this.settings);
  bool get displayAlarmButton => settings.displayAlarmButton;
  bool get displayDeleteButton => settings.displayDeleteButton;
  bool get displayEditButton => settings.displayEditButton;
  bool get displayQuarterHour => settings.displayQuarterHour;
  bool get displayTimeLeft => settings.displayTimeLeft;
  bool get activityDateEditable => settings.activityDateEditable;
}

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsLoaded(List<MemoplannerSettingData> settings)
      : super(MemoplannerSettings.fromSettingsList(settings));
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsNotLoaded() : super(MemoplannerSettings.defaultSettigs());
}

class MemoplannerSettings {
  static const String displayAlarmButtonKey =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButtonKey =
          'activity_detailed_setting_display_delete_button',
      displayEditButtonKey = 'activity_detailed_setting_display_edit_button',
      displayQuarterHourKey = 'activity_detailed_setting_display_qhw',
      displayTimeLeftKey = 'activity_detailed_setting_display_qhw_time_left',
      activityDateEditableKey = 'advanced_activity_date';

  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft,
      activityDateEditable;

  MemoplannerSettings({
    @required this.displayAlarmButton,
    @required this.displayDeleteButton,
    @required this.displayEditButton,
    @required this.displayQuarterHour,
    @required this.displayTimeLeft,
    @required this.activityDateEditable,
  });

  factory MemoplannerSettings.fromSettingsList(
      List<MemoplannerSettingData> settings) {
    return _parseSettings(settings);
  }

  factory MemoplannerSettings.defaultSettigs() {
    return MemoplannerSettings(
      displayAlarmButton: true,
      displayDeleteButton: true,
      displayEditButton: true,
      displayQuarterHour: true,
      displayTimeLeft: true,
      activityDateEditable: true,
    );
  }

  static MemoplannerSettings _parseSettings(
      List<MemoplannerSettingData> settings) {
    return MemoplannerSettings(
      displayAlarmButton: _parseSetting(displayAlarmButtonKey, settings, true),
      displayDeleteButton:
          _parseSetting(displayDeleteButtonKey, settings, true),
      displayEditButton: _parseSetting(displayEditButtonKey, settings, true),
      displayQuarterHour: _parseSetting(displayQuarterHourKey, settings, true),
      displayTimeLeft: _parseSetting(displayTimeLeftKey, settings, true),
      activityDateEditable:
          _parseSetting(activityDateEditableKey, settings, true),
    );
  }

  static T _parseSetting<T>(String settingName,
      List<MemoplannerSettingData> rawSettings, T defaultValue) {
    final setting = rawSettings.firstWhere((s) => s.identifier == settingName,
        orElse: () => null);
    if (setting == null) {
      return defaultValue;
    }
    return json.decode(setting.data);
  }
}
