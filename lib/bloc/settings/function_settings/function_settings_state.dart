part of 'function_settings_cubit.dart';

class FunctionSettingsState extends Equatable {
  final bool displayWeek,
      displayMonth,
      displayNewActivity,
      displayMenu,
      displayMenuInitial;
  final StartView startView;
  final int timeout;
  final bool useScreensaver;

  bool get hasTimeOut => timeout > 0;
  bool get shouldUseScreenSaver => hasTimeOut && useScreensaver;
  bool get displayMenuChangedToDisabled => !displayMenu && displayMenuInitial;

  FunctionSettingsState._({
    required this.displayWeek,
    required this.displayMonth,
    required this.displayNewActivity,
    required this.displayMenu,
    required this.displayMenuInitial,
    required this.timeout,
    required this.useScreensaver,
    required StartView startView,
  }) : startView = _startView(
          displayWeek,
          displayMonth,
          displayMenu,
          startView,
        );

  static StartView _startView(
    bool displayWeek,
    bool displayMonth,
    bool displayMenu,
    StartView startView,
  ) {
    switch (startView) {
      case StartView.weekCalendar:
        return displayWeek ? startView : StartView.dayCalendar;
      case StartView.monthCalendar:
        return displayMonth ? startView : StartView.dayCalendar;
      case StartView.menu:
        return displayMenu ? startView : StartView.dayCalendar;
      default:
        return startView;
    }
  }

  factory FunctionSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      FunctionSettingsState._(
        displayWeek: state.displayWeekCalendar,
        displayMonth: state.displayMonthCalendar,
        displayNewActivity: state.displayNewActivity,
        displayMenu: state.settings.functionMenuDisplayMenu,
        displayMenuInitial: state.settings.functionMenuDisplayMenu,
        timeout: state.activityTimeout,
        useScreensaver: state.useScreensaver,
        startView: state.startView,
      );

  FunctionSettingsState copyWith({
    bool? displayWeek,
    bool? displayMonth,
    bool? displayNewActivity,
    bool? displayMenu,
    int? timeout,
    bool? useScreensaver,
    StartView? startView,
  }) =>
      FunctionSettingsState._(
        displayWeek: displayWeek ?? this.displayWeek,
        displayMonth: displayMonth ?? this.displayMonth,
        displayNewActivity: displayNewActivity ?? this.displayNewActivity,
        displayMenu: displayMenu ?? this.displayMenu,
        timeout: timeout ?? this.timeout,
        useScreensaver: useScreensaver ?? this.useScreensaver,
        startView: startView ?? this.startView,
        displayMenuInitial: displayMenuInitial,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: displayWeek,
          identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayMonth,
          identifier: MemoplannerSettings.functionMenuDisplayMonthKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayNewActivity,
          identifier: MemoplannerSettings.functionMenuDisplayNewActivityKey,
        ),
        MemoplannerSettingData.fromData(
          data: displayMenu,
          identifier: MemoplannerSettings.functionMenuDisplayMenuKey,
        ),
        MemoplannerSettingData.fromData(
          data: timeout,
          identifier: MemoplannerSettings.activityTimeoutKey,
        ),
        MemoplannerSettingData.fromData(
          data: shouldUseScreenSaver,
          identifier: MemoplannerSettings.useScreensaverKey,
        ),
        MemoplannerSettingData.fromData(
          data: startView.index,
          identifier: MemoplannerSettings.functionMenuStartViewKey,
        ),
      ];

  @override
  List<Object> get props => [
        displayWeek,
        displayMonth,
        displayNewActivity,
        displayMenu,
        timeout,
        useScreensaver,
        startView,
      ];
}
