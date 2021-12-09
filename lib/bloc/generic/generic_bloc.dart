import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'generic_event.dart';
part 'generic_state.dart';

class GenericBloc extends Bloc<GenericEvent, GenericState> {
  final GenericRepository genericRepository;
  late final StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  GenericBloc({
    required this.genericRepository,
    required PushBloc pushBloc,
    required this.syncBloc,
  }) : super(GenericsNotLoaded()) {
    pushSubscription = pushBloc.stream.listen((state) {
      if (state is PushReceived) {
        add(LoadGenerics());
      }
    });
  }

  @override
  Stream<GenericState> mapEventToState(
    GenericEvent event,
  ) async* {
    if (event is LoadGenerics) {
      yield* _mapLoadGenericsToState();
    }
    if (event is GenericUpdated) {
      final currentState = state;
      if (currentState is GenericsLoaded) {
        final toUpdate = {
          for (var genericData
              in event.genericData.whereType<MemoplannerSettingData>())
            genericData.key: currentState.generics[genericData.key]
                    ?.copyWithNewData(newData: genericData) ??
                Generic.createNew<MemoplannerSettingData>(data: genericData)
        };

        yield GenericsLoaded(
          generics: Map<String, Generic>.from(currentState.generics)
            ..addAll(toUpdate),
        );

        final anyDirty = await genericRepository.save(toUpdate.values);
        if (anyDirty) {
          yield* _mapLoadGenericsToState();
          syncBloc.add(SyncEvent.genericSaved);
        }
      }
    }
  }

  Stream<GenericState> _mapLoadGenericsToState() async* {
    try {
      final generics = await genericRepository.load();
      yield GenericsLoaded(
        generics: generics.toGenericKeyMap(),
      );
    } catch (e) {
      yield GenericsLoadedFailed();
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    return super.close();
  }
}
