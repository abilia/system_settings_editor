import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class TimeoutSettings extends Equatable {
  static const activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      screenSaverOnlyDuringNightKey = 'screensaver_only_active_during_night';

  final Duration duration;
  final bool screensaver, onlyDuringNight;

  bool get hasDuration => duration > Duration.zero;
  bool get shouldUseScreenSaver => hasDuration && screensaver;

  const TimeoutSettings({
    this.duration = Duration.zero,
    this.screensaver = false,
    this.onlyDuringNight = false,
  });

  TimeoutSettings copyWith({
    Duration? duration,
    bool? screensaver,
    bool? onlyDuringNight,
  }) =>
      TimeoutSettings(
        duration: duration ?? this.duration,
        screensaver: screensaver ?? this.screensaver,
        onlyDuringNight: onlyDuringNight ?? this.onlyDuringNight,
      );

  factory TimeoutSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      TimeoutSettings(
        duration: Duration(milliseconds: settings.parse(activityTimeoutKey, 0)),
        screensaver: settings.getBool(
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
        screensaver,
        onlyDuringNight,
      ];
}
