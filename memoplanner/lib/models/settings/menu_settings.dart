import 'package:equatable/equatable.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';

class MenuSettings extends Equatable {
  bool get allDisabled =>
      !showCamera &&
      !showPhotos &&
      !showTemplates &&
      !showSettings &&
      !photoCalendarEnabled &&
      !quickSettingsEnabled;

  bool get quickSettingsEnabled => showQuickSettings && Config.isMP;
  bool get photoCalendarEnabled => showPhotoCalendar && Config.isMP;

  static const showCameraKey = 'settings_menu_show_camera',
      showPhotosKey = 'settings_menu_show_photos',
      showPhotoCalendarKey = 'settings_menu_show_photo_calendar',
      showTemplatesKey = 'settings_menu_show_basic_template',
      showQuickSettingsKey = 'settings_menu_show_quick_settings',
      showSettingsKey = 'settings_menu_show_settings';

  final bool showCamera,
      showPhotos,
      showPhotoCalendar,
      showTemplates,
      showQuickSettings,
      showSettings;

  const MenuSettings({
    this.showCamera = true,
    this.showPhotos = true,
    this.showPhotoCalendar = true,
    this.showTemplates = true,
    this.showQuickSettings = true,
    this.showSettings = true,
  });

  MenuSettings copyWith({
    bool? showCamera,
    bool? showPhotos,
    bool? showPhotoCalendar,
    bool? showTemplates,
    bool? showQuickSettings,
    bool? showSettings,
  }) =>
      MenuSettings(
        showCamera: showCamera ?? this.showCamera,
        showPhotos: showPhotos ?? this.showPhotos,
        showPhotoCalendar: showPhotoCalendar ?? this.showPhotoCalendar,
        showTemplates: showTemplates ?? this.showTemplates,
        showQuickSettings: showQuickSettings ?? this.showQuickSettings,
        showSettings: showSettings ?? this.showSettings,
      );

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
        showTemplates: settings.getBool(
          showTemplatesKey,
        ),
        showQuickSettings: settings.getBool(
          showQuickSettingsKey,
        ),
        showSettings: settings.getBool(
          showSettingsKey,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showCamera,
          identifier: MenuSettings.showCameraKey,
        ),
        MemoplannerSettingData.fromData(
          data: showPhotos,
          identifier: MenuSettings.showPhotosKey,
        ),
        MemoplannerSettingData.fromData(
          data: showPhotoCalendar,
          identifier: MenuSettings.showPhotoCalendarKey,
        ),
        MemoplannerSettingData.fromData(
          data: showTemplates,
          identifier: MenuSettings.showTemplatesKey,
        ),
        MemoplannerSettingData.fromData(
          data: showQuickSettings,
          identifier: MenuSettings.showQuickSettingsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showSettings,
          identifier: MenuSettings.showSettingsKey,
        ),
      ];

  @override
  List<Object?> get props => [
        showCamera,
        showPhotos,
        showPhotoCalendar,
        showTemplates,
        showQuickSettings,
        showSettings
      ];
}
