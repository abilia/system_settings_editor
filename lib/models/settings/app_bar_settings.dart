import 'package:equatable/equatable.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/memoplanner_settings.dart';

class AppBarSettings extends Equatable {
  final bool dayCaptionShowDayButtons,
      activityDisplayDayPeriod,
      activityDisplayWeekDay,
      activityDisplayDate,
      activityDisplayClock;

  const AppBarSettings({
    this.dayCaptionShowDayButtons = true,
    this.activityDisplayDayPeriod = true,
    this.activityDisplayWeekDay = true,
    this.activityDisplayDate = true,
    this.activityDisplayClock = true,
  });

  static const String dayCaptionShowDayButtonsKey =
          'day_caption_show_day_buttons',
      activityDisplayDayPeriodKey = 'day_caption_show_period',
      activityDisplayWeekDayKey = 'day_caption_show_weekday',
      activityDisplayDateKey = 'day_caption_show_date',
      activityDisplayClockKey = 'day_caption_show_clock';

  bool get displayDayCalendarAppBar =>
      activityDisplayDayPeriod ||
      activityDisplayWeekDay ||
      activityDisplayDate ||
      activityDisplayClock ||
      dayCaptionShowDayButtons;

  factory AppBarSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return AppBarSettings(
      dayCaptionShowDayButtons: settings.getBool(
        dayCaptionShowDayButtonsKey,
      ),
      activityDisplayDayPeriod: settings.getBool(
        activityDisplayDayPeriodKey,
      ),
      activityDisplayWeekDay: settings.getBool(
        activityDisplayWeekDayKey,
      ),
      activityDisplayDate: settings.getBool(
        activityDisplayDateKey,
      ),
      activityDisplayClock: settings.getBool(
        activityDisplayClockKey,
      ),
    );
  }

  @override
  List<Object> get props => [
        dayCaptionShowDayButtons,
        activityDisplayDayPeriod,
        activityDisplayWeekDay,
        activityDisplayDate,
        activityDisplayClock,
      ];
}
