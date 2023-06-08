import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class DayAppBarSettings extends Equatable {
  final bool showBrowseButtons, showWeekday, showDayPeriod, showDate, showClock;

  const DayAppBarSettings({
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
      showWeekday || showDayPeriod || showDate || showClock;

  factory DayAppBarSettings.fromSettingsMap(
      Map<String, GenericSettingData> settings) {
    return DayAppBarSettings(
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

  DayAppBarSettings copyWith({
    bool? showBrowseButtons,
    bool? showWeekday,
    bool? showDayPeriod,
    bool? showDate,
    bool? showClock,
  }) =>
      DayAppBarSettings(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekday: showWeekday ?? this.showWeekday,
        showDayPeriod: showDayPeriod ?? this.showDayPeriod,
        showDate: showDate ?? this.showDate,
        showClock: showClock ?? this.showClock,
      );

  List<GenericSettingData> get memoplannerSettingData => [
        GenericSettingData.fromData(
          data: showBrowseButtons,
          identifier: dayCaptionShowDayButtonsKey,
        ),
        GenericSettingData.fromData(
          data: showWeekday,
          identifier: activityDisplayWeekdayKey,
        ),
        GenericSettingData.fromData(
          data: showDayPeriod,
          identifier: activityDisplayDayPeriodKey,
        ),
        GenericSettingData.fromData(
          data: showDate,
          identifier: activityDisplayDateKey,
        ),
        GenericSettingData.fromData(
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
