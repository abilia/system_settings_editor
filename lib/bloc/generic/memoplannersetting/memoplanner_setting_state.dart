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
  bool get displayLocalImages => settings.imageMenuDisplayPhotoItem;
  bool get displayCamera => settings.imageMenuDisplayCameraItem;
  bool get displayMyPhotos => settings.imageMenuDisplayMyPhotosItem;

  bool get settingsInaccessible =>
      !settings.functions.display.menu || !settings.menu.showSettings;

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

  TimepillarIntervalType get timepillarIntervalType =>
      TimepillarIntervalType.values[settings.viewOptionsTimeInterval];
  DayCalendarType get dayCalendarType => DayCalendarType.values[
      min(settings.viewOptionsTimeView, DayCalendarType.values.length - 1)];
  TimepillarZoom get timepillarZoom =>
      TimepillarZoom.values[settings.viewOptionsZoom];

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
    return settings.calendar.dayParts
        .todayTimepillarIntervalFromType(now, timepillarIntervalType);
  }

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
