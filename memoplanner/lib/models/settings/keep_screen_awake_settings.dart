import 'package:equatable/equatable.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/memoplanner_settings.dart';

class KeepScreenAwakeSettings extends Equatable {
  static const keepScreenOnWhileChargingKey = 'keep_screen_on_while_charging';
  static const keepScreenOnAlwaysKey = 'keep_screen_on_always';

  static const keys = [
    keepScreenOnWhileChargingKey,
    keepScreenOnAlwaysKey,
  ];

  final bool keepScreenOnWhileCharging, keepScreenOnAlways;

  const KeepScreenAwakeSettings({
    this.keepScreenOnWhileCharging = false,
    this.keepScreenOnAlways = false,
  });

  KeepScreenAwakeSettings copyWith({
    bool? keepScreenOnWhileCharging,
    bool? keepScreenOnAlways,
  }) =>
      KeepScreenAwakeSettings(
        keepScreenOnWhileCharging:
            keepScreenOnWhileCharging ?? this.keepScreenOnWhileCharging,
        keepScreenOnAlways: keepScreenOnAlways ?? this.keepScreenOnAlways,
      );

  factory KeepScreenAwakeSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      KeepScreenAwakeSettings(
        keepScreenOnWhileCharging: settings.parse(
          keepScreenOnWhileChargingKey,
          false,
        ),
        keepScreenOnAlways: settings.parse(
          keepScreenOnAlwaysKey,
          false,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: keepScreenOnWhileCharging,
          identifier: keepScreenOnWhileChargingKey,
        ),
        MemoplannerSettingData.fromData(
          data: keepScreenOnAlways,
          identifier: keepScreenOnAlwaysKey,
        ),
      ];

  @override
  List<Object?> get props => [keepScreenOnWhileCharging, keepScreenOnAlways];
}
