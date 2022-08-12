import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class TimeoutSettings extends Equatable {
  static const activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      screenSaverOnlyDuringNightKey = 'screensaver_only_active_during_night';

  final Duration duration;
  final bool use, onlyDuringNight;

  bool get hasDuration => duration > Duration.zero;
  bool get shouldUseScreenSaver => hasDuration && use;

  const TimeoutSettings({
    this.duration = Duration.zero,
    this.use = false,
    this.onlyDuringNight = false,
  });

  TimeoutSettings copyWith({
    Duration? duration,
    bool? use,
    bool? onlyDuringNight,
  }) =>
      TimeoutSettings(
        duration: duration ?? this.duration,
        use: use ?? this.use,
        onlyDuringNight: onlyDuringNight ?? this.onlyDuringNight,
      );

  factory TimeoutSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      TimeoutSettings(
        duration: Duration(milliseconds: settings.parse(activityTimeoutKey, 0)),
        use: settings.getBool(
          useScreensaverKey,
          defaultValue: false,
        ),
        onlyDuringNight: settings.getBool(screenSaverOnlyDuringNightKey),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: duration.inMilliseconds,
          identifier: activityTimeoutKey,
        ),
        MemoplannerSettingData.fromData(
          data: shouldUseScreenSaver,
          identifier: useScreensaverKey,
        ),
        MemoplannerSettingData.fromData(
          data: onlyDuringNight,
          identifier: screenSaverOnlyDuringNightKey,
        ),
      ];

  @override
  List<Object> get props => [
        duration,
        use,
        onlyDuringNight,
      ];
}
