import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  static final _log = Logger((SortableBloc).toString());
  final SortableRepository sortableRepository;
  late final StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  SortableBloc({
    required this.sortableRepository,
    required PushBloc pushBloc,
    required this.syncBloc,
  }) : super(SortablesNotLoaded()) {
    pushSubscription = pushBloc.stream.listen((state) {
      if (state is PushReceived) {
        add(const LoadSortables());
      }
    });
  }

  @override
  Stream<SortableState> mapEventToState(
    SortableEvent event,
  ) async* {
    if (event is LoadSortables) {
      yield* _mapLoadSortablesToState(event.initDefaults);
    }
    if (event is PhotoAdded) {
      yield* _mapPhotoAddedToState(event);
    }
    if (event is ImageArchiveImageAdded) {
      yield* _mapImageArchiveImageAddedToState(event);
    }
    if (event is SortableUpdated) {
      yield* _mapSortableUpdatedToState(event);
    }
  }

  Stream<SortableState> _mapLoadSortablesToState(bool initDefaults) async* {
    try {
      final sortables = await sortableRepository.load();
      yield SortablesLoaded(sortables: sortables);
      if (initDefaults) {
        await _addMissingDefaults(sortables);
      }
    } catch (e) {
      _log.warning('exception when loadning sortable $e');
      yield SortablesLoadedFailed();
    }
  }

  Future<void> _addMissingDefaults(Iterable<Sortable> sortables) async {
    _addMissingMyPhotos(sortables);
    _addMissingUploadFolder(sortables);
  }

  Future<void> _addMissingMyPhotos(Iterable<Sortable> sortables) async {
    if (sortables.getMyPhotosFolder() == null) {
      final myPhotosFolder = await sortableRepository.createMyPhotosFolder();
      if (myPhotosFolder == null) {
        final myPhotos = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(myPhotos: true),
          sortOrder: startSordOrder,
          isGroup: true,
          fixed: true,
        );
        await sortableRepository.save([myPhotos]);
        syncBloc.add(SyncEvent.sortableSaved);
      } else {
        add(const LoadSortables());
      }
    }
  }

  Future<void> _addMissingUploadFolder(Iterable<Sortable> sortables) async {
    if (sortables.getUploadFolder() == null) {
      final uploadsFolder = await sortableRepository.createUploadsFolder();
      if (uploadsFolder == null) {
        final upload = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(upload: true),
          sortOrder: startSordOrder,
          isGroup: true,
          fixed: true,
        );
        await sortableRepository.save([upload]);
        syncBloc.add(SyncEvent.sortableSaved);
      } else {
        add(const LoadSortables());
      }
    }
  }

  Stream<SortableState> _mapImageArchiveImageAddedToState(
    ImageArchiveImageAdded event,
  ) async* {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      final uploadFolder = currentState.sortables.getUploadFolder();
      if (uploadFolder == null) return;
      final name = event.imagePath.split('/').last.split('.').first;

      yield* _mapPhotoAddedToState(
        PhotoAdded(
          event.imageId,
          event.imagePath,
          name,
          uploadFolder.id,
        ),
      );
    }
  }

  Stream<SortableState> _mapPhotoAddedToState(PhotoAdded event) async* {
    {
      final currentState = state;
      if (currentState is SortablesLoaded) {
        final sortableData = ImageArchiveData(
          name: event.name,
          file: '${FileStorage.folder}/${event.imageId}',
          fileId: event.imageId,
        );
        final folderContent = currentState.sortables
            .where((s) => s.groupId == event.folderId)
            .toList();
        folderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final sortOrder = folderContent.isEmpty
            ? startSordOrder
            : calculateNextSortOrder(folderContent.last.sortOrder, 1);
        final newSortable = Sortable.createNew<ImageArchiveData>(
          data: sortableData,
          groupId: event.folderId,
          sortOrder: sortOrder,
        );
        await sortableRepository.save([newSortable]);
        syncBloc.add(SyncEvent.sortableSaved);
        yield SortablesLoaded(
          sortables: currentState.sortables.followedBy([newSortable]),
        );
      }
    }
  }

  Stream<SortableState> _mapSortableUpdatedToState(
      SortableUpdated event) async* {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      await sortableRepository.save([event.sortable]);
      yield* _mapLoadSortablesToState(false);
      syncBloc.add(SyncEvent.sortableSaved);
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    return super.close();
  }
}
