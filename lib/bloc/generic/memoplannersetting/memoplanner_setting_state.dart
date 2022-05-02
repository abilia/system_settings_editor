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
  bool get activityDisplayDayPeriod => settings.activityDisplayDayPeriod;
  bool get activityDisplayWeekDay => settings.activityDisplayWeekDay;
  bool get activityDisplayDate => settings.activityDisplayDate;
  bool get activityDisplayClock => settings.activityDisplayClock;
  bool get displayDayCalendarAppBar =>
      activityDisplayDayPeriod ||
      activityDisplayWeekDay ||
      activityDisplayDate ||
      activityDisplayClock ||
      dayCaptionShowDayButtons;
  bool get showCategories => settings.calendarActivityTypeShowTypes;
  bool get showCategoryColor =>
      showCategories && settings.calendarActivityTypeShowColor;
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
      displayWeekCalendar ||
      displayNewTimer;
  bool get displayNewActivity => settings.functionMenuDisplayNewActivity;
  bool get displayNewTimer => settings.functionMenuDisplayNewTimer;
  bool get displayMenu =>
      settings.functionMenuDisplayMenu && !settings.menu.allDisabled;
  bool get useScreensaver => settings.useScreensaver;
  bool get displayLocalImages => settings.imageMenuDisplayPhotoItem;
  bool get displayCamera => settings.imageMenuDisplayCameraItem;
  bool get displayMyPhotos => settings.imageMenuDisplayMyPhotosItem;

  bool get settingsInaccessible => !displayMenu || !settings.menu.showSettings;

  bool get dotsInTimepillar => settings.dotsInTimepillar;
  bool get settingViewOptionsTimeView => settings.settingViewOptionsTimeView;
  bool get settingViewOptionsTimeInterval =>
      settings.settingViewOptionsTimeInterval;
  bool get settingViewOptionsZoom => settings.settingViewOptionsZoom;
  bool get settingViewOptionsDurationDots =>
      settings.settingViewOptionsDurationDots;

  bool get displayEyeButton =>
      settingViewOptionsTimeView ||
      (dayCalendarType == DayCalendarType.oneTimepillar &&
          (settingViewOptionsTimeInterval ||
              settingViewOptionsZoom ||
              settingViewOptionsDurationDots));

  bool get weekCaptionShowBrowseButtons =>
      settings.weekCaptionShowBrowseButtons;
  bool get weekCaptionShowWeekNumber => settings.weekCaptionShowWeekNumber;
  bool get weekCaptionShowYear => settings.weekCaptionShowYear;
  bool get weekCaptionShowClock => settings.weekCaptionShowClock;

  bool get monthCaptionShowBrowseButtons =>
      settings.monthCaptionShowMonthButtons;
  bool get monthCaptionShowYear => settings.monthCaptionShowYear;
  bool get monthCaptionShowClock => settings.monthCaptionShowClock;

  int get defaultAlarmTypeSetting => settings.activityDefaultAlarmType;

  int get morningStart => settings.morningIntervalStart;
  int get dayStart => settings.dayIntervalStart;
  int get eveningStart => settings.eveningIntervalStart;
  int get nightStart => settings.nightIntervalStart;
  Duration get activityTimeout =>
      Duration(milliseconds: settings.activityTimeout);

  int get weekCalendarTabIndex => (displayWeekCalendar ? 1 : 0);
  int get monthCalendarTabIndex =>
      weekCalendarTabIndex + (displayMonthCalendar ? 1 : 0);
  int get menuTabIndex => monthCalendarTabIndex + (displayMenu ? 1 : 0);
  int get calendarCount => menuTabIndex + 1;

  DayColor get calendarDayColor => DayColor.values[settings.calendarDayColor];
  TimepillarIntervalType get timepillarIntervalType =>
      TimepillarIntervalType.values[settings.viewOptionsTimeInterval];
  DayCalendarType get dayCalendarType => DayCalendarType.values[
      min(settings.viewOptionsTimeView, DayCalendarType.values.length - 1)];
  StartView get startView => StartView.values[settings.functionMenuStartView];
  TimepillarZoom get timepillarZoom =>
      TimepillarZoom.values[settings.viewOptionsZoom];
  ClockType get clockType => ClockType.values[settings.settingClockType];

  AlarmSettings get alarm => settings.alarm;

  NewActivityMode get addActivityType => settings.addActivityTypeAdvanced
      ? NewActivityMode.editView
      : NewActivityMode.stepByStep;

  bool get basicActivityOption =>
      (addActivityType == NewActivityMode.editView &&
          settings.editActivity.template) ||
      (addActivityType == NewActivityMode.stepByStep &&
          settings.stepByStep.template);

  bool get newActivityOption =>
      (addActivityType == NewActivityMode.editView &&
          (settings.editActivity.title || settings.editActivity.image)) ||
      (addActivityType == NewActivityMode.stepByStep &&
          (settings.stepByStep.title || settings.stepByStep.image));

  WeekDisplayDays get weekDisplayDays =>
      WeekDisplayDays.values[settings.weekDisplayShowFullWeek];

  WeekColor get weekColor =>
      WeekColor.values[settings.weekDisplayShowColorMode];
  WeekColor get monthWeekColor =>
      WeekColor.values[settings.calendarMonthViewShowColors];

  TimepillarInterval todayTimepillarInterval(DateTime now) {
    final day = now.onlyDays();
    switch (timepillarIntervalType) {
      case TimepillarIntervalType.interval:
        return dayPartInterval(now);
      case TimepillarIntervalType.day:
        if (now.isBefore(day.add(morningStart.milliseconds()))) {
          return TimepillarInterval(
            start: day,
            end: day.add(morningStart.milliseconds()),
            intervalPart: IntervalPart.night,
          );
        } else if (now
            .isAtSameMomentOrAfter(day.add(nightStart.milliseconds()))) {
          return TimepillarInterval(
            start: day.add(nightStart.milliseconds()),
            end: day.nextDay(),
            intervalPart: IntervalPart.night,
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
          intervalPart: IntervalPart.dayAndNight,
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
          end: base.add(dayStart.milliseconds()),
        );
      case DayPart.day:
        return TimepillarInterval(
          start: base.add(dayStart.milliseconds()),
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
            intervalPart: IntervalPart.night,
          );
        } else {
          return TimepillarInterval(
            start: base.add(nightStart.milliseconds()),
            end: base.nextDay(),
            intervalPart: IntervalPart.night,
          );
        }
    }
  }

  int startViewIndex(StartView startView) {
    switch (startView) {
      case StartView.weekCalendar:
        if (displayWeekCalendar) {
          return weekCalendarTabIndex;
        }
        break;
      case StartView.monthCalendar:
        if (displayMonthCalendar) {
          return monthCalendarTabIndex;
        }
        break;
      case StartView.menu:
        if (displayMenu) {
          return menuTabIndex;
        }
        break;
      default:
    }
    return 0;
  }

  DayParts get dayParts => DayParts(
        morningStart: morningStart,
        dayStart: dayStart,
        eveningStart: eveningStart,
        nightStart: nightStart,
      );

  String get leftCategoryName => settings.calendarActivityTypeLeft;
  String get rightCategoryName => settings.calendarActivityTypeRight;
  String get leftCategoryImage => settings.calendarActivityTypeLeftImage;
  String get rightCategoryImage => settings.calendarActivityTypeRightImage;

  @override
  List<Object> get props => settings.props;

  @override
  bool get stringify => true;
}

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  const MemoplannerSettingsLoaded(MemoplannerSettings settings)
      : super(settings);
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  const MemoplannerSettingsNotLoaded() : super(const MemoplannerSettings());
}

class MemoplannerSettingsFailed extends MemoplannerSettingsState {
  const MemoplannerSettingsFailed() : super(const MemoplannerSettings());
}
