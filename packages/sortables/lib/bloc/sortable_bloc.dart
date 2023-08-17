import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sortables/models/sortable/all.dart';
import 'package:sortables/repository/sortable_repository.dart';
import 'package:sortables/utils/extensions/all.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  static final _log = Logger((SortableBloc).toString());
  final SortableRepository sortableRepository;
  late final StreamSubscription _loadSortablesSubscription;
  StreamSubscription? _refreshAfterAddedStarterSetSubscription;
  final SyncBloc syncBloc;
  final String fileStorageFolder;

  SortableBloc({
    required this.sortableRepository,
    required this.syncBloc,
    required this.fileStorageFolder,
  }) : super(SortablesNotLoaded()) {
    _loadSortablesSubscription =
        syncBloc.stream.where((state) => state is SyncDone).listen((_) {
      final state = this.state;
      add(
        LoadSortables(
          initDefaults: state is SortablesNotLoaded ||
              state is SortablesLoaded && state.sortables.isEmpty,
        ),
      );
    });
    on<SortableEvent>(_onEvent, transformer: sequential());
  }

  Future<void> _onEvent(
    SortableEvent event,
    Emitter<SortableState> emit,
  ) async {
    if (event is LoadSortables) {
      await _mapLoadSortablesToState(event.initDefaults, emit);
    } else if (event is PhotoAdded) {
      await _mapPhotoAddedToState(event, emit);
    } else if (event is ImageArchiveImageAdded) {
      await _mapImageArchiveImageAddedToState(event, emit);
    } else if (event is SortablesUpdated) {
      await _mapSortablesUpdatedToState(event, emit);
    }
  }

  Future<void> _mapLoadSortablesToState(
      bool initDefaults, Emitter<SortableState> emit) async {
    try {
      final sortables = await sortableRepository.getAll();
      if (isClosed) return;
      emit(SortablesLoaded(sortables: sortables));
      if (initDefaults) {
        await _addMissingDefaults(sortables);
      }
    } catch (e) {
      _log.warning('exception when loading sortable $e');
      if (isClosed) return;
      emit(SortablesLoadedFailed());
    }
  }

  Future<void> _addMissingDefaults(Iterable<Sortable> sortables) async {
    await _addMissingMyPhotos(sortables);
    await _addMissingUploadFolder(sortables);
  }

  Future<void> _addMissingMyPhotos(Iterable<Sortable> sortables) async {
    if (sortables.getMyPhotosFolder() == null) {
      final myPhotosFolder = await sortableRepository.createMyPhotosFolder();
      if (myPhotosFolder == null) {
        final myPhotos = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(myPhotos: true),
          sortOrder: startSortOrder,
          isGroup: true,
          fixed: true,
        );
        await sortableRepository.save([myPhotos]);
        syncBloc.add(const SyncSortables());
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
          sortOrder: startSortOrder,
          isGroup: true,
          fixed: true,
        );
        await sortableRepository.save([upload]);
        syncBloc.add(const SyncSortables());
      } else {
        add(const LoadSortables());
      }
    }
  }

  Future<void> _mapImageArchiveImageAddedToState(
    ImageArchiveImageAdded event,
    Emitter<SortableState> emit,
  ) async {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      final uploadFolder = currentState.sortables.getUploadFolder();
      if (uploadFolder == null) return;

      await _mapPhotoAddedToState(
        PhotoAdded(
          event.imageId,
          event.name,
          uploadFolder.id,
        ),
        emit,
      );
    }
  }

  Future<void> _mapPhotoAddedToState(
    PhotoAdded event,
    Emitter<SortableState> emit,
  ) async {
    {
      final currentState = state;
      if (currentState is SortablesLoaded) {
        final sortableData = ImageArchiveData(
          name: event.name,
          file: '$fileStorageFolder/${event.imageId}',
          fileId: event.imageId,
          tags: UnmodifiableSetView(event.tags),
        );
        final sortOrder = currentState.sortables
            .firstSortOrderForFolder(folderId: event.folderId);
        final newSortable = Sortable.createNew<ImageArchiveData>(
          data: sortableData,
          groupId: event.folderId,
          sortOrder: sortOrder,
        );
        emit(
          SortablesLoaded(
            sortables: currentState.sortables.followedBy([newSortable]),
          ),
        );
        await sortableRepository.save([newSortable]);
        syncBloc.add(const SyncSortables());
      }
    }
  }

  Future<void> _mapSortablesUpdatedToState(
      SortablesUpdated event, Emitter<SortableState> emit) async {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      await sortableRepository.save(event.sortables);
      await _mapLoadSortablesToState(false, emit);
      syncBloc.add(const SyncSortables());
    }
  }

  Future<void> addStarter(String language) async {
    try {
      final success = await sortableRepository.applyTemplate(language);
      if (success) {
        _refreshAfterAddedStarterSetSubscription =
            Stream.periodic(const Duration(seconds: 10))
                .take(12)
                .listen((_) => add(const LoadSortables()));
      }
    } catch (error, stackTrace) {
      _log.warning('Could not add starter pack', error, stackTrace);
    }
  }

  @override
  Future<void> close() async {
    await _loadSortablesSubscription.cancel();
    await _refreshAfterAddedStarterSetSubscription?.cancel();
    return super.close();
  }
}
