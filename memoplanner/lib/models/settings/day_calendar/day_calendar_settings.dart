import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/models/all.dart';

class DayCalendarSettings extends Equatable {
  final AppBarSettings appBar;
  final DayCalendarViewOptionsSettings viewOptions;

  const DayCalendarSettings({
    this.appBar = const AppBarSettings(),
    this.viewOptions = const DayCalendarViewOptionsSettings(),
    Key? key,
  });

  factory DayCalendarSettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      DayCalendarSettings(
        appBar: AppBarSettings.fromSettingsMap(settings),
        viewOptions: DayCalendarViewOptionsSettings.fromSettingsMap(settings),
      );

  DayCalendarSettings copyWith({
    AppBarSettings? appBar,
    DayCalendarViewOptionsSettings? viewOptions,
  }) =>
      DayCalendarSettings(
        appBar: appBar ?? this.appBar,
        viewOptions: viewOptions ?? this.viewOptions,
      );

  List<GenericSettingData> get memoplannerSettingData => [
        ...appBar.memoplannerSettingData,
        ...viewOptions.memoplannerSettingData,
      ];

  @override
  List<Object> get props => [
        appBar,
        viewOptions,
      ];
}
