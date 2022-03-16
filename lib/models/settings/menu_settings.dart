import 'package:equatable/equatable.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';

class MenuSettings extends Equatable {
  bool get allDisabled =>
      !showCamera &&
      !showPhotos &&
      !showSettings &&
      !photoCalendarEnabled &&
      !quickSettingsEnabled;

  bool get quickSettingsEnabled => showQuickSettings && Config.isMP;
  bool get photoCalendarEnabled => showPhotoCalendar && Config.isMP;

  static const showCameraKey = 'settings_menu_show_camera',
      showPhotosKey = 'settings_menu_show_photos',
      showPhotoCalendarKey = 'settings_menu_show_photo_calendar',
      showTimersKey = 'settings_menu_show_timers',
      showQuickSettingsKey = 'settings_menu_show_quick_settings',
      showSettingsKey = 'settings_menu_show_settings';

  final bool showCamera,
      showPhotos,
      showSettings,
      showPhotoCalendar,
      showQuickSettings;

  const MenuSettings({
    this.showCamera = true,
    this.showPhotos = true,
    this.showPhotoCalendar = true,
    this.showQuickSettings = true,
    this.showSettings = true,
  });

  factory MenuSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      MenuSettings(
        showCamera: settings.getBool(
          showCameraKey,
        ),
        showPhotos: settings.getBool(
          showPhotosKey,
        ),
        showPhotoCalendar: settings.getBool(
          showPhotoCalendarKey,
        ),
        showQuickSettings: settings.getBool(
          showQuickSettingsKey,
        ),
        showSettings: settings.getBool(
          showSettingsKey,
        ),
      );

  @override
  List<Object?> get props => [
        showCamera,
        showPhotos,
        showPhotoCalendar,
        showQuickSettings,
        showSettings
      ];
}
