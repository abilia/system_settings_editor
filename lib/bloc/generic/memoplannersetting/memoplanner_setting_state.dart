// @dart=2.9

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
  bool get advancedActivityTemplate => settings.advancedActivityTemplate;
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
  bool get activityDisplayClock => settings.activityDisplayClock;
  bool get displayDayCalendarAppBar =>
      activityDisplayDayPeriod ||
      activityDisplayWeekDay ||
      activityDisplayDate ||
      activityDisplayClock ||
      dayCaptionShowDayButtons;
  bool get showCategories => settings.calendarActivityTypeShowTypes;
  bool get showColor => settings.calendarActivityTypeShowColor;
  bool get timepillar12HourFormat => settings.setting12hTimeFormatTimeline;
  bool get displayHourLines => settings.settingDisplayHourLines;
  bool get displayTimeline => settings.settingDisplayTimeline;
  bool get vibrateAtReminder => settings.vibrateAtReminder;
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

  bool get settingsInaccessible => !displayMenu || !displayMenuSettings;

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
  bool get dotsInTimepillar => settings.dotsInTimepillar;
  bool get settingViewOptionsTimeView => settings.settingViewOptionsTimeView;
  bool get settingViewOptionsTimeInterval =>
      settings.settingViewOptionsTimeInterval;
  bool get settingViewOptionsZoom => settings.settingViewOptionsZoom;
  bool get settingViewOptionsDurationDots =>
      settings.settingViewOptionsDurationDots;

  bool get displayEyeButton =>
      settingViewOptionsTimeView ||
      (dayCalendarType == DayCalendarType.TIMEPILLAR &&
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

  bool get wizardTemplateStep => settings.wizardTemplateStep;
  bool get wizardTitleStep => settings.wizardTitleStep;
  bool get wizardImageStep => settings.wizardImageStep;
  bool get wizardDatePickerStep => settings.wizardDatePickerStep;
  bool get wizardTypeStep => settings.wizardTypeStep;
  bool get wizardCheckableStep => settings.wizardCheckableStep;
  bool get wizardAvailabilityType => settings.wizardAvailabilityType;
  bool get wizardRemoveAfterStep => settings.wizardRemoveAfterStep;
  bool get wizardAlarmStep => settings.wizardAlarmStep;
  bool get wizardChecklistStep => settings.wizardChecklistStep;
  bool get wizardNotesStep => settings.wizardNotesStep;
  bool get wizardRemindersStep => settings.wizardRemindersStep;

  int get defaultAlarmTypeSetting => settings.activityDefaultAlarmType;

  int get morningStart => settings.morningIntervalStart;
  int get dayStart => settings.dayIntervalStart;
  int get eveningStart => settings.eveningIntervalStart;
  int get nightStart => settings.nightIntervalStart;
  int get alarmDuration => settings.alarmDuration;
  int get activityTimeout => settings.activityTimeout;

  int get calendarCount =>
      1 + (displayWeekCalendar ? 1 : 0) + (displayMonthCalendar ? 1 : 0);

  DayColor get calendarDayColor => DayColor.values[settings.calendarDayColor];
  TimepillarIntervalType get timepillarIntervalType =>
      TimepillarIntervalType.values[settings.viewOptionsTimeInterval];
  DayCalendarType get dayCalendarType => DayCalendarType.values[
      min(settings.viewOptionsTimeView, DayCalendarType.values.length - 1)];
  StartView get startView => StartView.values[settings.functionMenuStartView];
  TimepillarZoom get timepillarZoom =>
      TimepillarZoom.values[settings.viewOptionsZoom];
  ClockType get clockType => ClockType.values[settings.settingClockType];
  Sound get nonCheckableAlarm => settings.nonCheckableActivityAlarm == null
      ? Sound.Default
      : settings.nonCheckableActivityAlarm.toSound();
  Sound get checkableAlarm => settings.checkableActivityAlarm == null
      ? Sound.Default
      : settings.checkableActivityAlarm.toSound();
  Sound get reminderAlarm => settings.reminderAlarm == null
      ? Sound.Default
      : settings.reminderAlarm.toSound();

  NewActivityMode get addActivityType => settings.addActivityTypeAdvanced
      ? NewActivityMode.editView
      : NewActivityMode.stepByStep;

  WeekDisplayDays get weekDisplayDays =>
      WeekDisplayDays.values[settings.weekDisplayShowFullWeek];

  WeekColor get weekColor =>
      WeekColor.values[settings.weekDisplayShowColorMode];
  WeekColor get monthWeekColor =>
      WeekColor.values[settings.calendarMonthViewShowColors];

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
        dayStart,
        eveningStart,
        nightStart,
      );

  String get leftCategoryName => settings.calendarActivityTypeLeft;
  String get rightCategoryName => settings.calendarActivityTypeRight;
  String get leftCategoryImage => settings.calendarActivityTypeLeftImage;
  String get rightCategoryImage => settings.calendarActivityTypeRightImage;

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        settings.activityDisplayAlarmOption,
        settings.activityDisplaySilentAlarmOption, // for Vibration
        settings.activityDisplaySilentAlarmOption, // and Silent
        settings.activityDisplayNoAlarmOption
      ].where((e) => e).length >=
      2;

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
