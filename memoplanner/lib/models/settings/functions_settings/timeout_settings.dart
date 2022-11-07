import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class TimeoutSettings extends Equatable {
  static const timeoutOptions = [0, 10, 5, 1];

  static const activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      screensaverOnlyDuringNightKey = 'screensaver_only_active_during_night';

  final Duration duration;
  final bool screensaver, screensaverOnlyDuringNight;

  bool get hasDuration => duration > Duration.zero;
  bool get shouldUseScreensaver => hasDuration && screensaver;

  const TimeoutSettings({
    this.duration = Duration.zero,
    this.screensaver = false,
    this.screensaverOnlyDuringNight = false,
  });

  TimeoutSettings copyWith({
    Duration? duration,
    bool? screensaver,
    bool? screensaverOnlyDuringNight,
  }) =>
      TimeoutSettings(
        duration: duration ?? this.duration,
        screensaver: screensaver ?? this.screensaver,
        screensaverOnlyDuringNight:
            screensaverOnlyDuringNight ?? this.screensaverOnlyDuringNight,
      );

  factory TimeoutSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      TimeoutSettings(
        duration: Duration(milliseconds: settings.parse(activityTimeoutKey, 0)),
        screensaver: settings.getBool(
          useScreensaverKey,
          defaultValue: false,
        ),
        screensaverOnlyDuringNight: settings.getBool(
          screensaverOnlyDuringNightKey,
          defaultValue: false,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: duration.inMilliseconds,
          identifier: activityTimeoutKey,
        ),
        MemoplannerSettingData.fromData(
          data: shouldUseScreensaver,
          identifier: useScreensaverKey,
        ),
        MemoplannerSettingData.fromData(
          data: screensaverOnlyDuringNight && screensaver,
          identifier: screensaverOnlyDuringNightKey,
        ),
      ];

  @override
  List<Object> get props => [
        duration,
        screensaver,
        screensaverOnlyDuringNight,
      ];
}
