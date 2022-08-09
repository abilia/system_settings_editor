import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class FunctionSettings extends Equatable {
  static const functionMenuStartViewKey = 'function_menu_start_view';

  final DisplaySettings display;
  final ScreensaverSettings screensaver;
  final StartView _startView;

  int get startViewIndex {
    switch (startView) {
      case StartView.weekCalendar:
        if (display.week) {
          return display.weekCalendarTabIndex;
        }
        break;
      case StartView.monthCalendar:
        if (display.month) {
          return display.monthCalendarTabIndex;
        }
        break;
      case StartView.menu:
        if (display.month) {
          return display.menuTabIndex;
        }
        break;
      case StartView.photoAlbum:
        return display.photoAlbumTabIndex;
      default:
    }
    return 0;
  }

  StartView get startView {
    switch (_startView) {
      case StartView.weekCalendar:
        return display.week ? _startView : StartView.dayCalendar;
      case StartView.monthCalendar:
        return display.month ? _startView : StartView.dayCalendar;
      case StartView.menu:
        return display.menu ? _startView : StartView.dayCalendar;
      default:
        return _startView;
    }
  }

  const FunctionSettings({
    this.display = const DisplaySettings(),
    this.screensaver = const ScreensaverSettings(),
    StartView startView = StartView.dayCalendar,
  }) : _startView = startView;

  FunctionSettings copyWith({
    DisplaySettings? display,
    ScreensaverSettings? screensaver,
    StartView? startView,
  }) =>
      FunctionSettings(
        display: display ?? this.display,
        screensaver: screensaver ?? this.screensaver,
        startView: startView ?? this.startView,
      );

  factory FunctionSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      FunctionSettings(
        display: DisplaySettings.fromSettingsMap(settings),
        screensaver: ScreensaverSettings.fromSettingsMap(settings),
        startView:
            StartView.values[settings.parse(functionMenuStartViewKey, 0)],
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        ...display.memoplannerSettingData,
        ...screensaver.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: startView.index,
          identifier: functionMenuStartViewKey,
        ),
      ];

  @override
  List<Object> get props => [
        display,
        screensaver,
        _startView,
      ];
}
