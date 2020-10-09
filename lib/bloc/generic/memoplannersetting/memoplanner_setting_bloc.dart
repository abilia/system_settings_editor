import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'memoplanner_setting_state.dart';
part 'memoplanner_setting_event.dart';

class MemoplannerSettingBloc
    extends Bloc<MemoplannerSettingsEvent, MemoplannerSettingsState> {
  StreamSubscription _genericSubscription;

  MemoplannerSettingBloc({@required GenericBloc genericBloc})
      : super(genericBloc.state is GenericsLoaded
            ? MemoplannerSettingsLoaded(
                MemoplannerSettings.fromSettingsList(
                  _filter((genericBloc.state as GenericsLoaded).generics),
                ),
              )
            : MemoplannerSettingsNotLoaded()) {
    _genericSubscription = genericBloc.listen((state) {
      if (state is GenericsLoaded) {
        add(UpdateMemoplannerSettings(state.generics));
      }
    });
  }

  @override
  Stream<MemoplannerSettingsState> mapEventToState(
      MemoplannerSettingsEvent event) async* {
    if (event is UpdateMemoplannerSettings) {
      yield MemoplannerSettingsLoaded(
          MemoplannerSettings.fromSettingsList(_filter(event.generics)));
    }
  }

  static List<MemoplannerSettingData> _filter(List<Generic> generics) {
    final memoSettings = generics.whereType<Generic<MemoplannerSettingData>>();
    return memoSettings.map((ms) => ms.data).toList();
  }

  @override
  Future<void> close() async {
    await _genericSubscription.cancel();
    return super.close();
  }
}
