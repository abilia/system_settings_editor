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
  const MemoplannerSettingsState();
  T getSetting<T>(String settingName, T defaultValue);
}

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  final List<MemoplannerSettingData> settings;

  MemoplannerSettingsLoaded(this.settings);

  @override
  T getSetting<T>(String settingName, T defaultValue) {
    final setting = settings.firstWhere((s) => s.identifier == settingName,
        orElse: () => null);
    if (setting == null) {
      return defaultValue;
    }
    return json.decode(setting.data);
  }
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  @override
  T getSetting<T>(String settingName, T defaultValue) {
    return defaultValue;
  }
}
