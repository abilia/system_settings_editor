import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class GeneralCalendarSettings extends Equatable {
  static const settingClockTypeKey = 'setting_clock_type',
      calendarDayColorKey = 'calendar_daycolor';
  final ClockType clockType;
  final TimepillarSettings timepillar;
  final DayParts dayParts;
  final DayColor dayColor;
  final CategoriesSettings categories;

  const GeneralCalendarSettings({
    this.clockType = ClockType.analogueDigital,
    this.timepillar = const TimepillarSettings(),
    this.dayParts = const DayParts(),
    this.dayColor = DayColor.allDays,
    this.categories = const CategoriesSettings(),
  });

  factory GeneralCalendarSettings.fromSettingsMap(
    Map<String, GenericSettingData> settings,
  ) =>
      GeneralCalendarSettings(
        clockType: ClockType.values[settings.parse(settingClockTypeKey, 0)],
        timepillar: TimepillarSettings.fromSettingsMap(settings),
        dayParts: DayParts.fromSettingsMap(settings),
        dayColor: DayColor.values[settings.parse(calendarDayColorKey, 0)],
        categories: CategoriesSettings.fromSettingsMap(settings),
      );

  GeneralCalendarSettings copyWith({
    ClockType? clockType,
    TimepillarSettings? timepillar,
    DayParts? dayParts,
    DayColor? dayColor,
    CategoriesSettings? categories,
  }) =>
      GeneralCalendarSettings(
        clockType: clockType ?? this.clockType,
        timepillar: timepillar ?? this.timepillar,
        dayParts: dayParts ?? this.dayParts,
        dayColor: dayColor ?? this.dayColor,
        categories: categories ?? this.categories,
      );

  List<GenericSettingData> get memoplannerSettingData => [
        GenericSettingData.fromData(
          data: clockType.index,
          identifier: settingClockTypeKey,
        ),
        ...timepillar.memoplannerSettingData,
        ...dayParts.memoplannerSettingData,
        GenericSettingData.fromData(
          data: dayColor.index,
          identifier: calendarDayColorKey,
        ),
        ...categories.memoplannerSettingData,
      ];

  @override
  List<Object> get props => [
        clockType,
        timepillar,
        dayParts,
        dayColor,
        categories,
      ];
}
