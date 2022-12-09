import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/generic/generic.dart';
import 'package:memoplanner/models/settings/memoplanner_settings.dart';

class AppBarSettings extends Equatable {
  final bool showBrowseButtons, showWeekday, showDayPeriod, showDate, showClock;

  const AppBarSettings({
    this.showBrowseButtons = true,
    this.showWeekday = true,
    this.showDayPeriod = true,
    this.showDate = true,
    this.showClock = true,
  });

  static const String dayCaptionShowDayButtonsKey =
          'day_caption_show_day_buttons',
      activityDisplayDayPeriodKey = 'day_caption_show_period',
      activityDisplayWeekdayKey = 'day_caption_show_weekday',
      activityDisplayDateKey = 'day_caption_show_date',
      activityDisplayClockKey = 'day_caption_show_clock';

  bool get displayDayCalendarAppBar =>
      showWeekday ||
      showDayPeriod ||
      showDate ||
      showClock ||
      showBrowseButtons;

  factory AppBarSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return AppBarSettings(
      showBrowseButtons: settings.getBool(
        dayCaptionShowDayButtonsKey,
      ),
      showWeekday: settings.getBool(
        activityDisplayWeekdayKey,
      ),
      showDayPeriod: settings.getBool(
        activityDisplayDayPeriodKey,
      ),
      showDate: settings.getBool(
        activityDisplayDateKey,
      ),
      showClock: settings.getBool(
        activityDisplayClockKey,
      ),
    );
  }

  AppBarSettings copyWith({
    bool? showBrowseButtons,
    bool? showWeekday,
    bool? showDayPeriod,
    bool? showDate,
    bool? showClock,
  }) =>
      AppBarSettings(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekday: showWeekday ?? this.showWeekday,
        showDayPeriod: showDayPeriod ?? this.showDayPeriod,
        showDate: showDate ?? this.showDate,
        showClock: showClock ?? this.showClock,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: dayCaptionShowDayButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showWeekday,
          identifier: activityDisplayWeekdayKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDayPeriod,
          identifier: activityDisplayDayPeriodKey,
        ),
        MemoplannerSettingData.fromData(
          data: showDate,
          identifier: activityDisplayDateKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: activityDisplayClockKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
        showWeekday,
        showDayPeriod,
        showDate,
        showClock,
      ];
}
