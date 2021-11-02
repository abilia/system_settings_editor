import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class CodeProtectSettings extends Equatable {
  static const defaultCode = '0353';
  static const codeKey = 'settings_codeprotect_code',
      protectSettingsKey = 'codeprotect_settings',
      protectCodeProtectKey = 'codeprotect_code_protection_settings',
      protectAndroidSettingsKey = 'codeprotect_android_settings';

  static const keys = [
    codeKey,
    protectSettingsKey,
    protectCodeProtectKey,
    protectAndroidSettingsKey,
  ];

  final String code;
  final bool protectSettings, protectCodeProtect, protectAndroidSettings;

  const CodeProtectSettings({
    this.code = defaultCode,
    this.protectSettings = false,
    this.protectCodeProtect = false,
    this.protectAndroidSettings = false,
  });

  CodeProtectSettings copyWith({
    String? code,
    bool? protectSettings,
    bool? protectCodeProtect,
    bool? protectAndroidSettings,
  }) =>
      CodeProtectSettings(
        code: code ?? this.code,
        protectSettings: protectSettings ?? this.protectSettings,
        protectCodeProtect: protectCodeProtect ?? this.protectCodeProtect,
        protectAndroidSettings:
            protectAndroidSettings ?? this.protectAndroidSettings,
      );
  factory CodeProtectSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      CodeProtectSettings(
        code: settings.parse(
          codeKey,
          defaultCode,
        ),
        protectSettings: settings.parse(
          protectSettingsKey,
          false,
        ),
        protectAndroidSettings: settings.parse(
          protectAndroidSettingsKey,
          false,
        ),
        protectCodeProtect: settings.parse(
          protectCodeProtectKey,
          false,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: code,
          identifier: codeKey,
        ),
        MemoplannerSettingData.fromData(
          data: protectSettings,
          identifier: protectSettingsKey,
        ),
        MemoplannerSettingData.fromData(
          data: protectCodeProtect,
          identifier: protectCodeProtectKey,
        ),
        MemoplannerSettingData.fromData(
          data: protectAndroidSettings,
          identifier: protectAndroidSettingsKey,
        ),
      ];

  @override
  List<Object?> get props => [
        code,
        protectSettings,
        protectCodeProtect,
        protectAndroidSettings,
      ];
}
