import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/generic/generic.dart';
import 'package:memoplanner/models/settings/memoplanner_settings.dart';

@Deprecated(
  'To be Remove on in 4.3, '
  'use SettingsDb.keepScreenOnWhileCharging instead',
)
class KeepScreenAwakeSettings extends Equatable {
  static const keepScreenOnWhileChargingKey = 'keep_screen_on_while_charging';
  static const keepScreenOnAlwaysKey = 'keep_screen_on_always';

  final bool _keepScreenOnWhileCharging, _keepScreenOnAlways;

  bool get keepScreenOnWhileCharging => _keepScreenOnWhileCharging;

  bool get keepScreenOnAlways => _keepScreenOnAlways;

  const KeepScreenAwakeSettings({
    bool keepScreenOnWhileCharging = false,
    bool keepScreenOnAlways = false,
  })  : _keepScreenOnWhileCharging = keepScreenOnWhileCharging,
        _keepScreenOnAlways = keepScreenOnAlways;

  factory KeepScreenAwakeSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    final savedKeepOnWhileCharging =
        settings.parse(keepScreenOnWhileChargingKey, false);
    final savedKeepOnAlways = settings.parse(keepScreenOnAlwaysKey, false);
    return KeepScreenAwakeSettings(
      keepScreenOnWhileCharging: savedKeepOnWhileCharging,
      keepScreenOnAlways: savedKeepOnAlways,
    );
  }

  @override
  List<Object?> get props => [keepScreenOnWhileCharging, keepScreenOnAlways];
}
