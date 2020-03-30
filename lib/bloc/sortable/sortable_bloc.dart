import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/sortable_repository.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  final SortableRepository sortableRepository;
  StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  SortableBloc({
    @required this.sortableRepository,
    @required PushBloc pushBloc,
    @required this.syncBloc,
  }) {
    pushSubscription = pushBloc.listen((state) {
      if (state is PushReceived) {
        add(LoadSortables());
      }
    });
  }

  @override
  SortableState get initialState => SortablesNotLoaded();

  @override
  Stream<SortableState> mapEventToState(
    SortableEvent event,
  ) async* {
    if (event is LoadSortables) {
      yield* _mapLoadSortablesToState();
    }
    if (event is ImageArchiveImageAdded) {
      yield* _mapImageArchiveImageAddedToState(event);
    }
  }

  Stream<SortableState> _mapLoadSortablesToState() async* {
    try {
      final sortables = await sortableRepository.load();
      yield SortablesLoaded(sortables: sortables);
    } catch (_) {
      yield SortablesLoadedFailed();
    }
  }

  Stream<SortableState> _mapImageArchiveImageAddedToState(
      ImageArchiveImageAdded event) async* {
    print('Image archive added: $event');
    final currentState = state;
    if (currentState is SortablesLoaded) {
      final uploadFolder =
          await getOrGenerateUploadFolder(currentState.sortables);
      final name = event.imagePath.split('/').last.split('.').first;
      final sortableData = SortableData(
        name: name,
        file: event.imagePath,
        fileId: event.imageId,
      ).toJson();
      final newSortable = Sortable.createNew(
        type: SortableType.imageArchive,
        data: json.encode(sortableData),
        groupId: uploadFolder.id,
        sortOrder: 'A', // TODO generate more correct sort order
      );
      await sortableRepository.save([newSortable]);
      print('Image archive sortable added now sending message to syncbloc');
      syncBloc.add(SortableSaved());
      print('yielding sortablesLoaded');
      yield SortablesLoaded(
        sortables: currentState.sortables.followedBy([newSortable]),
      );
    }
  }

  Future<Sortable> getOrGenerateUploadFolder(
      Iterable<Sortable> sortables) async {
    try {
      return sortables.firstWhere(
        (s) => json.decode(s.data)['upload'] ?? false,
      );
    } catch (e) {
      print('No upload folder. Create one');
      return sortableRepository.generateUploadFolder();
    }
  }

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
