part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsEvent extends Equatable {
  const MemoplannerSettingsEvent();
  @override
  bool get stringify => true;
}

class UpdateMemoplannerSettings extends MemoplannerSettingsEvent {
  final MapView<String, Generic> generics;

  UpdateMemoplannerSettings(this.generics);

  @override
  List<Object> get props => [generics];
}

class GenericsFailedEvent extends MemoplannerSettingsEvent {
  @override
  List<Object> get props => [];
}

class SettingsUpdateEvent<T> extends MemoplannerSettingsEvent {
  final String identifier;
  final T data;
  MemoplannerSettingData get settingData =>
      MemoplannerSettingData.fromData(data: data, identifier: identifier);
  const SettingsUpdateEvent(this.identifier, this.data);
  @override
  List<Object> get props => [identifier, data];
}

class ZoomSettingUpdatedEvent extends SettingsUpdateEvent {
  final TimepillarZoom timepillarZoom;

  ZoomSettingUpdatedEvent(this.timepillarZoom)
      : super(MemoplannerSettings.viewOptionsZoomKey, timepillarZoom.index);
}

class IntervalTypeUpdatedEvent extends SettingsUpdateEvent {
  final TimepillarIntervalType timepillarIntervalType;

  IntervalTypeUpdatedEvent(this.timepillarIntervalType)
      : super(MemoplannerSettings.viewOptionsTimeIntervalKey,
            timepillarIntervalType.index);
}

class DayCalendarTypeUpdatedEvent extends SettingsUpdateEvent {
  final DayCalendarType dayCalendarType;

  DayCalendarTypeUpdatedEvent(this.dayCalendarType)
      : super(
            MemoplannerSettings.viewOptionsTimeViewKey, dayCalendarType.index);
}
