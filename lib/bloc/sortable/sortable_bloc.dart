import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/sortable_repository.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  static final _log = Logger((SortableBloc).toString());
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
    final currentState = state;
    if (currentState is SortablesLoaded) {
      final uploadFolder =
          await getOrGenerateUploadFolder(currentState.sortables);
      final name = event.imagePath.split('/').last.split('.').first;
      final sortableData = SortableData(
        name: name,
        file: '${FileStorage.folder}/${event.imageId}',
        fileId: event.imageId,
      ).toJson();

      final uploadFolderContent = currentState.sortables
          .where((s) => s.groupId == uploadFolder.id)
          .toList();
      uploadFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = uploadFolderContent.isEmpty
          ? getStartSortOrder()
          : calculateNextSortOrder(uploadFolderContent.last.sortOrder, 1);

      final newSortable = Sortable.createNew(
        type: SortableType.imageArchive,
        data: json.encode(sortableData),
        groupId: uploadFolder.id,
        sortOrder: sortOrder,
      );
      await sortableRepository.save([newSortable]);
      syncBloc.add(SortableSaved());
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
      _log.info('No upload folder. Create one');
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
