part of 'memoplanner_settings_bloc.dart';

abstract class MemoplannerSettingsEvent extends Equatable {
  const MemoplannerSettingsEvent();
  @override
  bool get stringify => true;
}

class UpdateMemoplannerSettings extends MemoplannerSettingsEvent {
  final MapView<String, Generic> generics;

  const UpdateMemoplannerSettings(this.generics);

  @override
  List<Object> get props => [generics];
}

class GenericsFailedEvent extends MemoplannerSettingsEvent {
  @override
  List<Object> get props => [];
}

class SettingsUpdateEvent<T extends Object> extends MemoplannerSettingsEvent {
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
      : super(DayCalendarViewOptionsSettings.viewOptionsTimepillarZoomKey,
            timepillarZoom.index);
}

class IntervalTypeUpdatedEvent extends SettingsUpdateEvent {
  final TimepillarIntervalType timepillarIntervalType;

  IntervalTypeUpdatedEvent(this.timepillarIntervalType)
      : super(DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
            timepillarIntervalType.index);
}

class DayCalendarTypeUpdatedEvent extends SettingsUpdateEvent {
  final DayCalendarType dayCalendarType;

  DayCalendarTypeUpdatedEvent(this.dayCalendarType)
      : super(DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey,
            dayCalendarType.index);
}

class DotsInTimepillarUpdatedEvent extends SettingsUpdateEvent {
  final bool dotsInTimepillar;

  const DotsInTimepillarUpdatedEvent(this.dotsInTimepillar)
      : super(DayCalendarViewOptionsSettings.viewOptionsDotsKey,
            dotsInTimepillar);
}
