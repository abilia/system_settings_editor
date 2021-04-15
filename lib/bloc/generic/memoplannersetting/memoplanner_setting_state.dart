part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsState extends Equatable {
  final MemoplannerSettings settings;
  const MemoplannerSettingsState(this.settings);
  bool get displayAlarmButton => settings.displayAlarmButton;
  bool get displayDeleteButton => settings.displayDeleteButton;
  bool get displayEditButton => settings.displayEditButton;
  bool get displayQuarterHour => settings.displayQuarterHour;
  bool get displayTimeLeft => settings.displayTimeLeft;
  bool get dayCaptionShowDayButtons => settings.dayCaptionShowDayButtons;
  bool get activityDateEditable => settings.activityDateEditable;
  bool get activityTypeEditable => settings.activityTypeEditable;
  bool get activityEndTimeEditable => settings.activityEndTimeEditable;
  bool get activityTimeBeforeCurrent => settings.activityTimeBeforeCurrent;
  bool get activityRecurringEditable => settings.activityRecurringEditable;
  bool get activityDisplayAlarmOption => settings.activityDisplayAlarmOption;
  bool get activityDisplaySilentAlarmOption =>
      settings.activityDisplaySilentAlarmOption;
  bool get activityDisplayNoAlarmOption =>
      settings.activityDisplayNoAlarmOption;
  bool get activityDisplayDayPeriod => settings.activityDisplayDayPeriod;
  bool get activityDisplayWeekDay => settings.activityDisplayWeekDay;
  bool get activityDisplayDate => settings.activityDisplayDate;
  bool get showCategories => settings.calendarActivityTypeShowTypes;
  bool get timepillar12HourFormat => settings.setting12hTimeFormatTimeline;
  bool get displayHourLines => settings.settingDisplayHourLines;
  bool get displayTimeline => settings.settingDisplayTimeline;
  bool get columnOfDots => settings.settingTimePillarTimeline;
  bool get displayWeekCalendar => settings.functionMenuDisplayWeek;
  bool get displayMonthCalendar => settings.functionMenuDisplayMonth;
  bool get displayOnlyDayCalendar =>
      !displayWeekCalendar && !displayMonthCalendar;
  bool get displayBottomBar =>
      displayMenu ||
      displayNewActivity ||
      displayMonthCalendar ||
      displayWeekCalendar;
  bool get displayNewActivity => settings.functionMenuDisplayNewActivity;
  bool get displayMenu =>
      settings.functionMenuDisplayMenu && !allMenuItemsDisabled;
  bool get useScreensaver => settings.useScreensaver;
  bool get displayPhotos => settings.imageMenuDisplayPhotoItem;
  bool get displayCamera => settings.imageMenuDisplayCameraItem;

  bool get settingsInaccessable => !displayMenu || !displayMenuSettings;

  bool get allMenuItemsDisabled =>
      !displayMenuCamera &&
      !displayMenuMyPhotos &&
      !displayMenuPhotoCalendar &&
      !displayMenuCountdown &&
      !displayMenuQuickSettings &&
      !displayMenuSettings;
  bool get displayMenuCamera => settings.settingsMenuShowCamera;
  bool get displayMenuMyPhotos => settings.settingsMenuShowPhotos;
  bool get displayMenuPhotoCalendar => settings.settingsMenuShowPhotoCalendar;
  bool get displayMenuCountdown => settings.settingsMenuShowTimers;
  bool get displayMenuQuickSettings => settings.settingsMenuShowQuickSettings;
  bool get displayMenuSettings => settings.settingsMenuShowSettings;

  int get morningStart => settings.morningIntervalStart;
  int get forenoonStart => settings.forenoonIntervalStart;
  int get afternoonStart => settings.afternoonIntervalStart;
  int get eveningStart => settings.eveningIntervalStart;
  int get nightStart => settings.nightIntervalStart;
  int get activityTimeout => settings.activityTimeout;

  int get calendarCount =>
      1 + (displayWeekCalendar ? 1 : 0) + (displayMonthCalendar ? 1 : 0);

  DayColor get calendarDayColor => DayColor.values[settings.calendarDayColor];
  TimepillarIntervalType get timepillarIntervalType =>
      TimepillarIntervalType.values[settings.viewOptionsTimeInterval];
  StartView get startView => StartView.values[settings.functionMenuStartView];
  TimepillarZoom get timepillarZoom =>
      TimepillarZoom.values[settings.viewOptionsZoom];
  ClockType get clockType => ClockType.values[settings.settingClockType];

  TimepillarInterval todayTimepillarInterval(DateTime now) {
    final day = now.onlyDays();
    switch (timepillarIntervalType) {
      case TimepillarIntervalType.INTERVAL:
        return dayPartInterval(now);
      case TimepillarIntervalType.DAY:
        if (now.isBefore(day.add(morningStart.milliseconds()))) {
          return TimepillarInterval(
            start: day,
            end: day.add(morningStart.milliseconds()),
            intervalPart: IntervalPart.NIGHT,
          );
        } else if (now
            .isAtSameMomentOrAfter(day.add(nightStart.milliseconds()))) {
          return TimepillarInterval(
            start: day.add(nightStart.milliseconds()),
            end: day.nextDay(),
            intervalPart: IntervalPart.NIGHT,
          );
        }
        return TimepillarInterval(
          start: day.add(morningStart.milliseconds()),
          end: day.add(nightStart.milliseconds()),
        );
      default:
        return TimepillarInterval(
          start: day,
          end: day.nextDay(),
          intervalPart: IntervalPart.DAY_AND_NIGHT,
        );
    }
  }

  TimepillarInterval dayPartInterval(DateTime now) {
    final part = now.dayPart(dayParts);
    final base = now.onlyDays();
    switch (part) {
      case DayPart.morning:
        return TimepillarInterval(
          start: base.add(morningStart.milliseconds()),
          end: base.add(forenoonStart.milliseconds()),
        );
      case DayPart.forenoon:
        return TimepillarInterval(
          start: base.add(forenoonStart.milliseconds()),
          end: base.add(afternoonStart.milliseconds()),
        );
      case DayPart.afternoon:
        return TimepillarInterval(
          start: base.add(afternoonStart.milliseconds()),
          end: base.add(eveningStart.milliseconds()),
        );
      case DayPart.evening:
        return TimepillarInterval(
          start: base.add(eveningStart.milliseconds()),
          end: base.add(nightStart.milliseconds()),
        );
      case DayPart.night:
        if (now.isBefore(base.add(morningStart.milliseconds()))) {
          return TimepillarInterval(
            start: base,
            end: base.add(morningStart.milliseconds()),
            intervalPart: IntervalPart.NIGHT,
          );
        } else {
          return TimepillarInterval(
            start: base.add(nightStart.milliseconds()),
            end: base.nextDay(),
            intervalPart: IntervalPart.NIGHT,
          );
        }
    }
    throw ArgumentError();
  }

  DayParts get dayParts => DayParts(
        morningStart,
        forenoonStart,
        afternoonStart,
        eveningStart,
        nightStart,
      );

  String get leftCategoryName => settings.calendarActivityTypeLeft;
  String get rightCategoryName => settings.calendarActivityTypeRight;

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        settings.activityDisplayAlarmOption,
        settings.activityDisplaySilentAlarmOption, // for Vibration
        settings.activityDisplaySilentAlarmOption, // and Silent
        settings.activityDisplayNoAlarmOption
      ].where((e) => e).length >=
      2;

  int defaultAlarmType() {
    if (settings.activityDisplayAlarmOption) {
      return ALARM_SOUND_AND_VIBRATION;
    }
    if (settings.activityDisplaySilentAlarmOption) {
      return ALARM_VIBRATION;
    }
    if (settings.activityDisplayNoAlarmOption) {
      return NO_ALARM;
    }
    return ALARM_SOUND_AND_VIBRATION;
  }

  @override
  List<Object> get props => settings.props;

  @override
  bool get stringify => true;
}

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsLoaded(MemoplannerSettings settings) : super(settings);
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsNotLoaded() : super(MemoplannerSettings());
}

class MemoplannerSettingsFailed extends MemoplannerSettingsState {
  MemoplannerSettingsFailed() : super(MemoplannerSettings());
}

enum TimepillarIntervalType {
  INTERVAL,
  DAY,
  DAY_AND_NIGHT,
}

enum IntervalPart {
  DAY,
  NIGHT,
  DAY_AND_NIGHT,
}

enum TimepillarZoom {
  SMALL,
  NORMAL,
  LARGE,
}

extension ZoomExtension on TimepillarZoom {
  double get zoomValue {
    switch (this) {
      case TimepillarZoom.SMALL:
        return 0.75;
      case TimepillarZoom.NORMAL:
        return 1;
      case TimepillarZoom.LARGE:
        return 1.3;
      default:
        return 1;
    }
  }
}

class TimepillarInterval extends Equatable {
  final DateTime startTime, endTime;
  final IntervalPart intervalPart;

  TimepillarInterval({
    DateTime start,
    DateTime end,
    this.intervalPart = IntervalPart.DAY,
  })  : startTime = start.copyWith(minute: 0),
        endTime = end.copyWith(minute: 0);

  int get lengthInHours =>
      (endTime.difference(startTime).inMinutes / 60).ceil();

  List<ActivityOccasion> getForInterval(List<ActivityOccasion> activities) {
    return activities
        .where((a) =>
            a.start.inRangeWithInclusiveStart(
                startDate: startTime, endDate: endTime) ||
            (a.start.isBefore(startTime) && a.end.isAfter(startTime)))
        .toList();
  }

  @override
  List<Object> get props => [startTime, endTime];
  @override
  bool get stringify => true;
}
