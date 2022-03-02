import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'memoplanner_setting_state.dart';
part 'memoplanner_setting_event.dart';

class MemoplannerSettingBloc
    extends Bloc<MemoplannerSettingsEvent, MemoplannerSettingsState> {
  /// GenericBloc are null when faked in settings
  final GenericCubit? genericCubit;
  late final StreamSubscription? _genericSubscription;

  MemoplannerSettingBloc({this.genericCubit})
      : super(genericCubit?.state is GenericsLoaded
            ? MemoplannerSettingsLoaded(
                MemoplannerSettings.fromSettingsMap(
                  (genericCubit?.state as GenericsLoaded)
                      .generics
                      .filterMemoplannerSettingsData(),
                ),
              )
            : const MemoplannerSettingsNotLoaded()) {
    _genericSubscription = genericCubit?.stream.listen((state) {
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
      yield const MemoplannerSettingsFailed();
    }
    if (event is SettingsUpdateEvent) {
      genericCubit?.genericUpdated([event.settingData]);
    }
  }

  @override
  Future<void> close() async {
    await _genericSubscription?.cancel();
    return super.close();
  }
}
