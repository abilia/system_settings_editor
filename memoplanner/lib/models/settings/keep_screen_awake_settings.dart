import 'package:equatable/equatable.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/generic/generic.dart';
import 'package:memoplanner/models/settings/memoplanner_settings.dart';

class KeepScreenAwakeSettings extends Equatable {
  static const keepScreenOnWhileChargingKey = 'keep_screen_on_while_charging';
  static const keepScreenOnAlwaysKey = 'keep_screen_on_always';

  static const keys = [
    keepScreenOnWhileChargingKey,
    keepScreenOnAlwaysKey,
  ];

  final bool _keepScreenOnWhileCharging, _keepScreenOnAlways;

  bool get keepScreenOnWhileCharging =>
      Config.isMPLarge || _keepScreenOnWhileCharging;

  bool get keepScreenOnAlways => Config.isMPLarge || _keepScreenOnAlways;

  const KeepScreenAwakeSettings({
    bool? keepScreenOnWhileCharging,
    bool? keepScreenOnAlways,
  })  : _keepScreenOnWhileCharging = keepScreenOnWhileCharging ?? false,
        _keepScreenOnAlways = keepScreenOnAlways ?? false;

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
      Map<String, MemoplannerSettingData> settings) {
    final savedKeepOnWhileCharging =
        settings.parse(keepScreenOnWhileChargingKey, false);
    final savedKeepOnAlways = settings.parse(keepScreenOnAlwaysKey, false);
    return KeepScreenAwakeSettings(
      keepScreenOnWhileCharging: Config.isMPLarge || savedKeepOnWhileCharging,
      keepScreenOnAlways: Config.isMPLarge || savedKeepOnAlways,
    );
  }

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
