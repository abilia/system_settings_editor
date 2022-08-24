import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class TimepillarSettings extends Equatable {
  static const setting12hTimeFormatTimelineKey =
          'setting_12h_time_format_timeline',
      settingDisplayTimelineKey = 'setting_display_line_timeline',
      settingDisplayHourLinesKey = 'setting_display_hour_lines',
      settingTimePillarTimelineKey = 'setting_time_pillar_timeline';

  final bool timeline, hourLines, columnOfDots, use12h;

  const TimepillarSettings({
    this.use12h = false,
    this.timeline = true,
    this.hourLines = true,
    this.columnOfDots = false,
  });

  factory TimepillarSettings.fromSettingsMap(
    Map<String, MemoplannerSettingData> settings,
  ) =>
      TimepillarSettings(
        use12h: settings.getBool(
          setting12hTimeFormatTimelineKey,
          defaultValue: false,
        ),
        timeline: settings.getBool(
          settingDisplayTimelineKey,
        ),
        hourLines: settings.getBool(
          settingDisplayHourLinesKey,
          defaultValue: false,
        ),
        columnOfDots: settings.getBool(
          settingTimePillarTimelineKey,
          defaultValue: false,
        ),
      );

  TimepillarSettings copyWith({
    bool? use12h,
    bool? timeline,
    bool? hourLines,
    bool? columnOfDots,
  }) =>
      TimepillarSettings(
        use12h: use12h ?? this.use12h,
        timeline: timeline ?? this.timeline,
        hourLines: hourLines ?? this.hourLines,
        columnOfDots: columnOfDots ?? this.columnOfDots,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: use12h,
          identifier: setting12hTimeFormatTimelineKey,
        ),
        MemoplannerSettingData.fromData(
          data: timeline,
          identifier: settingDisplayTimelineKey,
        ),
        MemoplannerSettingData.fromData(
          data: hourLines,
          identifier: settingDisplayHourLinesKey,
        ),
        MemoplannerSettingData.fromData(
          data: columnOfDots,
          identifier: settingTimePillarTimelineKey,
        ),
      ];

  @override
  List<Object> get props => [
        use12h,
        timeline,
        hourLines,
        columnOfDots,
      ];
}