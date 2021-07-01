import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'memoplanner_setting_state.dart';
part 'memoplanner_setting_event.dart';

class MemoplannerSettingBloc
    extends Bloc<MemoplannerSettingsEvent, MemoplannerSettingsState> {
  late final StreamSubscription? _genericSubscription;
  final GenericBloc? genericBloc;

  MemoplannerSettingBloc({this.genericBloc})
      : super(genericBloc?.state is GenericsLoaded
            ? MemoplannerSettingsLoaded(
                MemoplannerSettings.fromSettingsMap(
                  (genericBloc?.state as GenericsLoaded)
                      .generics
                      .filterMemoplannerSettingsData(),
                ),
              )
            : MemoplannerSettingsNotLoaded()) {
    _genericSubscription = genericBloc?.stream.listen((state) {
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
        MemoplannerSettings.fromSettingsMap(
          event.generics.filterMemoplannerSettingsData(),
        ),
      );
    }
    if (event is GenericsLoadedFailed) {
      yield MemoplannerSettingsFailed();
    }
    if (event is SettingsUpdateEvent) {
      genericBloc?.add(GenericUpdated([event.settingData]));
    }
  }

  @override
  Future<void> close() async {
    await _genericSubscription?.cancel();
    return super.close();
  }
}
