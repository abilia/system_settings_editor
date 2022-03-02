import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'generic_state.dart';

class GenericCubit extends Cubit<GenericState> {
  final GenericRepository genericRepository;
  late final StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  GenericCubit({
    required this.genericRepository,
    required PushCubit pushCubit,
    required this.syncBloc,
  }) : super(GenericsNotLoaded()) {
    pushSubscription = pushCubit.stream.listen((state) {
      if (state is PushReceived) {
        _mapLoadGenericsToState();
      }
    });
  }

  void loadGenerics() {
    _mapLoadGenericsToState();
  }

  void genericUpdated(Iterable<GenericData> genericData) async {
    final currentState = state;
    if (currentState is GenericsLoaded) {
      final toUpdate = {
        for (var generic in genericData.whereType<MemoplannerSettingData>())
          generic.key: currentState.generics[generic.key]
                  ?.copyWithNewData(newData: generic) ??
              Generic.createNew<MemoplannerSettingData>(data: generic)
      };

      emit(
        GenericsLoaded(
          generics: Map<String, Generic>.from(currentState.generics)
            ..addAll(toUpdate),
        ),
      );

      final anyDirty = await genericRepository.save(toUpdate.values);
      if (anyDirty) {
        _mapLoadGenericsToState();
        syncBloc.add(const GenericSaved());
      }
    }
  }

  void _mapLoadGenericsToState() async {
    try {
      final generics = await genericRepository.load();
      emit(
        GenericsLoaded(
          generics: generics.toGenericKeyMap(),
        ),
      );
    } catch (e) {
      emit(GenericsLoadedFailed());
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    return super.close();
  }
}
