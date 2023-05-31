import 'dart:async';
import 'dart:collection';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';

part 'generic_state.dart';

class GenericCubit extends Cubit<GenericState> {
  final GenericRepository genericRepository;
  late final StreamSubscription syncSubscription;
  final SyncBloc syncBloc;

  GenericCubit({
    required this.genericRepository,
    required this.syncBloc,
  }) : super(GenericsNotLoaded()) {
    syncSubscription = syncBloc.stream.listen((state) async => loadGenerics());
  }

  Future<void> genericUpdated(Iterable<GenericData> genericData) async {
    final currentState = state;
    if (currentState is GenericsLoaded) {
      final toUpdate = {
        for (var generic in genericData.whereType<GenericSettingData>())
          generic.key: currentState.generics[generic.key]
                  ?.copyWithNewData(newData: generic) ??
              Generic.createNew<GenericSettingData>(data: generic)
      };

      emit(
        GenericsLoaded(
          generics: Map<String, Generic>.from(currentState.generics)
            ..addAll(toUpdate),
        ),
      );

      final anyDirty = await genericRepository.save(toUpdate.values);
      if (anyDirty) {
        syncBloc.add(const SyncGenerics());
        await loadGenerics();
      }
    }
  }

  Future<void> loadGenerics() async {
    try {
      final generics = await genericRepository.getAll();
      emit(
        generics.isNotEmpty || syncBloc.hasSynced
            ? GenericsLoaded(generics: generics.toGenericKeyMap())
            : GenericsNotLoaded(),
      );
    } catch (e) {
      emit(GenericsLoadedFailed());
    }
  }

  @override
  Future<void> close() async {
    await syncSubscription.cancel();
    return super.close();
  }
}
