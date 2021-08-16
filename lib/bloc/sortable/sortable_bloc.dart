import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
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
        add(LoadSortables());
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
      yield SortablesLoaded(
        sortables: [
          ...sortables,
          if (initDefaults) ...await getMissingDefaults(sortables),
        ],
      );
    } catch (e) {
      _log.warning('exception when loadning sortable $e');
      yield SortablesLoadedFailed();
    }
  }

  Future<List<Sortable>> getMissingDefaults(
      Iterable<Sortable> sortables) async {
    final sortOrder = sortables.firstSortOrderInFolder();
    final defaults = [
      if (sortables.getMyPhotosFolder() == null && Config.isMP)
        Sortable.createNew<ImageArchiveData>(
          data: ImageArchiveData(myPhotos: true),
          isGroup: true,
          sortOrder: sortOrder,
        ),
      if (sortables.getUploadFolder() == null)
        Sortable.createNew<ImageArchiveData>(
          data: ImageArchiveData(name: 'myAbilia', upload: true),
          isGroup: true,
          sortOrder: sortOrder,
        )
    ];
    if (defaults.isNotEmpty) {
      await sortableRepository.save(defaults);
      syncBloc.add(SortableSaved());
    }
    return defaults;
  }

  Stream<SortableState> _mapImageArchiveImageAddedToState(
      ImageArchiveImageAdded event) async* {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      final uploadFolder = currentState.sortables.getUploadFolder();
      if (uploadFolder == null) return;

      final name = event.imagePath.split('/').last.split('.').first;
      final sortableData = ImageArchiveData(
        name: name,
        file: '${FileStorage.folder}/${event.imageId}',
        fileId: event.imageId,
      );

      final uploadFolderContent = currentState.sortables
          .where((s) => s.groupId == uploadFolder.id)
          .toList();
      uploadFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = uploadFolderContent.isEmpty
          ? START_SORT_ORDER
          : calculateNextSortOrder(uploadFolderContent.last.sortOrder, 1);

      final newSortable = Sortable.createNew<ImageArchiveData>(
        data: sortableData,
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

  Stream<SortableState> _mapSortableUpdatedToState(
      SortableUpdated event) async* {
    final currentState = state;
    if (currentState is SortablesLoaded) {
      await sortableRepository.save([event.sortable]);
      yield* _mapLoadSortablesToState(false);
      syncBloc.add(SortableSaved());
    }
  }

  @override
  Future<void> close() async {
    await pushSubscription.cancel();
    return super.close();
  }
}
