part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsState extends Equatable {
  final MemoplannerSettings settings;

  const MemoplannerSettingsState(this.settings);

  bool get settingsInaccessible =>
      !settings.functions.display.menu || !settings.menu.showSettings;

  bool get monthCaptionShowBrowseButtons =>
      settings.monthCaptionShowMonthButtons;
  bool get monthCaptionShowYear => settings.monthCaptionShowYear;
  bool get monthCaptionShowClock => settings.monthCaptionShowClock;

  AlarmSettings get alarm => settings.alarm;

  WeekColor get monthWeekColor =>
      WeekColor.values[settings.calendarMonthViewShowColors];

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
