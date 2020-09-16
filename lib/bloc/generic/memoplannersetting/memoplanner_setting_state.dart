part of 'memoplanner_setting_bloc.dart';

class ActivityViewSetting {
  static const String displayAlarmButton =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButton = 'activity_detailed_setting_display_delete_button',
      displayEditButton = 'activity_detailed_setting_display_edit_button',
      displayQuarterHour = 'activity_detailed_setting_display_qhw',
      displayTimeLeft = 'activity_detailed_setting_display_qhw_time_left';
}

abstract class MemoplannerSettingsState {
  final MemoplannerSettings settings;
  const MemoplannerSettingsState(this.settings);
  bool get displayAlarmButton => settings.displayAlarmButton;
  bool get displayDeleteButton => settings.displayDeleteButton;
  bool get displayEditButton => settings.displayEditButton;
  bool get displayQuarterHour => settings.displayQuarterHour;
  bool get displayTimeLeft => settings.displayTimeLeft;

  static MemoplannerSettings get defaultSettings => MemoplannerSettings(
        displayAlarmButton: true,
        displayDeleteButton: true,
        displayEditButton: true,
        displayQuarterHour: true,
        displayTimeLeft: true,
      );
}

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsLoaded(List<MemoplannerSettingData> settings)
      : super(_parseSettings(settings));

  static MemoplannerSettings _parseSettings(
      List<MemoplannerSettingData> settings) {
    return MemoplannerSettings(
      displayAlarmButton:
          _parseSetting(ActivityViewSetting.displayAlarmButton, settings, true),
      displayDeleteButton: _parseSetting(
          ActivityViewSetting.displayDeleteButton, settings, true),
      displayEditButton:
          _parseSetting(ActivityViewSetting.displayEditButton, settings, true),
      displayQuarterHour:
          _parseSetting(ActivityViewSetting.displayQuarterHour, settings, true),
      displayTimeLeft:
          _parseSetting(ActivityViewSetting.displayTimeLeft, settings, true),
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

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsNotLoaded()
      : super(MemoplannerSettingsState.defaultSettings);
}

class MemoplannerSettings {
  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft;

  MemoplannerSettings({
    @required this.displayAlarmButton,
    @required this.displayDeleteButton,
    @required this.displayEditButton,
    @required this.displayQuarterHour,
    @required this.displayTimeLeft,
  });
}
