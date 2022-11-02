import 'dart:async';
import 'dart:collection';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'memoplanner_settings_event.dart';

class MemoplannerSettingsBloc
    extends Bloc<MemoplannerSettingsEvent, MemoplannerSettings> {
  /// GenericBloc are null when faked in settings
  final GenericCubit? genericCubit;
  late final StreamSubscription? _genericSubscription;

  MemoplannerSettingsBloc({this.genericCubit})
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
    on<MemoplannerSettingsEvent>(_onEvent, transformer: sequential());
  }
  Future _onEvent(
    MemoplannerSettingsEvent event,
    Emitter<MemoplannerSettings> emit,
  ) async {
    if (event is UpdateMemoplannerSettings) {
      await _mapUpdateMemoplannerSettings(event, emit);
    }
    if (event is GenericsLoadedFailed) {
      await _mapMemoplannerSettingsFailed(emit);
    }
    if (event is SettingsUpdateEvent) {
      genericCubit?.genericUpdated([event.settingData]);
    }
  }

  Future _mapUpdateMemoplannerSettings(UpdateMemoplannerSettings event,
      Emitter<MemoplannerSettings> emit) async {
    emit(MemoplannerSettingsLoaded(
      MemoplannerSettings.fromSettingsMap(
        event.generics.filterMemoplannerSettingsData(),
      ),
    ));
  }

  Future _mapMemoplannerSettingsFailed(
      Emitter<MemoplannerSettings> emit) async {
    emit(const MemoplannerSettingsFailed());
  }

  @override
  Future<void> close() async {
    await _genericSubscription?.cancel();
    return super.close();
  }
}
