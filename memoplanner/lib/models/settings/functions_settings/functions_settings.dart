import 'package:equatable/equatable.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/all.dart';

class FunctionsSettings extends Equatable {
  static const functionMenuStartViewKey = 'function_menu_start_view';

  final DisplaySettings display;
  final TimeoutSettings timeout;
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
        return Config.isMP ? display.photoAlbumTabIndex : 0;
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

  const FunctionsSettings({
    this.display = const DisplaySettings(),
    this.timeout = const TimeoutSettings(),
    StartView startView = StartView.dayCalendar,
  }) : _startView = startView;

  FunctionsSettings copyWith({
    DisplaySettings? display,
    TimeoutSettings? timeout,
    StartView? startView,
  }) =>
      FunctionsSettings(
        display: display ?? this.display,
        timeout: timeout ?? this.timeout,
        startView: startView ?? this.startView,
      );

  factory FunctionsSettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      FunctionsSettings(
        display: DisplaySettings.fromSettingsMap(settings),
        timeout: TimeoutSettings.fromSettingsMap(settings),
        startView:
            StartView.values[settings.parse(functionMenuStartViewKey, 0)],
      );

  List<GenericSettingData> get memoplannerSettingData => [
        ...display.memoplannerSettingData,
        ...timeout.memoplannerSettingData,
        GenericSettingData.fromData(
          data: startView.index,
          identifier: functionMenuStartViewKey,
        ),
      ];

  @override
  List<Object> get props => [
        display,
        timeout,
        _startView,
      ];
}
