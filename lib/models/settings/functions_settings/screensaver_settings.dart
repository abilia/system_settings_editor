import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class ScreensaverSettings extends Equatable {
  static const activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      screenSaverOnlyDuringNightKey = 'screensaver_only_active_during_night';

  final Duration timeout;
  final bool use, onlyDuringNight;

  bool get hasTimeOut => timeout > Duration.zero;
  bool get shouldUseScreenSaver => hasTimeOut && use;

  const ScreensaverSettings({
    this.timeout = Duration.zero,
    this.use = false,
    this.onlyDuringNight = false,
  });

  ScreensaverSettings copyWith({
    Duration? timeout,
    bool? use,
    bool? onlyDuringNight,
  }) =>
      ScreensaverSettings(
        timeout: timeout ?? this.timeout,
        use: use ?? this.use,
        onlyDuringNight: onlyDuringNight ?? this.onlyDuringNight,
      );

  factory ScreensaverSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      ScreensaverSettings(
        timeout: Duration(milliseconds: settings.parse(activityTimeoutKey, 0)),
        use: settings.getBool(
          useScreensaverKey,
          defaultValue: false,
        ),
        onlyDuringNight: settings.getBool(screenSaverOnlyDuringNightKey),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: timeout.inMilliseconds,
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
        timeout,
        use,
        onlyDuringNight,
      ];
}
