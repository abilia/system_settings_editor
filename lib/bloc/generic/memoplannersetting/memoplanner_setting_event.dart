part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsEvent {}

class UpdateMemoplannerSettings extends MemoplannerSettingsEvent {
  final List<Generic> generics;

  UpdateMemoplannerSettings(this.generics);
}

class GenericsFailedEvent extends MemoplannerSettingsEvent {}

class ZoomSettingUpdatedEvent extends MemoplannerSettingsEvent {
  final TimepillarZoom timepillarZoom;

  ZoomSettingUpdatedEvent(this.timepillarZoom);
}

class IntervalTypeUpdatedEvent extends MemoplannerSettingsEvent {
  final TimepillarIntervalType timepillarIntervalType;

  IntervalTypeUpdatedEvent(this.timepillarIntervalType);
}
