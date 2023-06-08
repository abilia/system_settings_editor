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
  GenericSettingData get settingData =>
      GenericSettingData.fromData(data: data, identifier: identifier);
  const SettingsUpdateEvent(this.identifier, this.data);
  @override
  List<Object> get props => [identifier, data];
}
