import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'memoplanner_setting_state.dart';
part 'memoplanner_setting_event.dart';

class MemoplannerSettingBloc
    extends Bloc<MemoplannerSettingsEvent, MemoplannerSettingsState> {
  StreamSubscription _genericSubscription;
  final GenericBloc genericBloc;

  MemoplannerSettingBloc({@required this.genericBloc})
      : super(genericBloc.state is GenericsLoaded
            ? MemoplannerSettingsLoaded(
                MemoplannerSettings.fromSettingsMap(
                  _filter((genericBloc.state as GenericsLoaded).generics),
                ),
              )
            : MemoplannerSettingsNotLoaded()) {
    _genericSubscription = genericBloc.listen((state) {
      if (state is GenericsLoaded) {
        add(UpdateMemoplannerSettings(state.generics));
      } else if (state is GenericsLoadedFailed) {
        add(GenericsFailedEvent());
      }
    });
  }

  @override
  Stream<MemoplannerSettingsState> mapEventToState(
      MemoplannerSettingsEvent event) async* {
    if (event is UpdateMemoplannerSettings) {
      yield MemoplannerSettingsLoaded(
          MemoplannerSettings.fromSettingsMap(_filter(event.generics)));
    }
    if (event is GenericsLoadedFailed) {
      yield MemoplannerSettingsFailed();
    }
    if (event is SettingsUpdateEvent) {
      genericBloc.add(GenericUpdated(event.settingData));
    }
  }

  static Map<String, MemoplannerSettingData> _filter(
      Map<String, Generic> generics) {
    return (generics.map((key, value) => MapEntry(key, value.data))
          ..removeWhere((key, value) => value is! MemoplannerSettingData))
        .cast<String, MemoplannerSettingData>();
  }

  @override
  Future<void> close() async {
    await _genericSubscription.cancel();
    return super.close();
  }
}
