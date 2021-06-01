import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/sortable/sortable.dart';
import 'package:collection/collection.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

part 'my_photos_state.dart';
part 'my_photos_event.dart';

class MyPhotosBloc extends Bloc<MyPhotosEvent, MyPhotosState> {
  StreamSubscription sortableSubscription;
  SortableBloc sortableBloc;
  MyPhotosBloc({@required this.sortableBloc})
      : super(MyPhotosState(
            allByFolder: {}, allById: {}, currentFolderId: null)) {
    sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        add(SortablesArrived(sortableState.sortables));
      }
    });
    final sortableState = sortableBloc.state;
    if (sortableState is SortablesLoaded) {
      add(SortablesArrived(sortableState.sortables));
    }
  }

  @override
  Stream<MyPhotosState> mapEventToState(MyPhotosEvent event) async* {
    if (event is SortablesArrived) {
      yield* _mapSortablesArrivedToState(event);
    }
    if (event is PhotoAdded) {
      yield* _mapPhotoAddedtoState(event);
    }
  }

  Stream<MyPhotosState> _mapSortablesArrivedToState(
      SortablesArrived event) async* {
    final imageArchiveSortables =
        event.sortables.whereType<Sortable<ImageArchiveData>>();
    final myPhotosRoot = imageArchiveSortables.getMyPhotosFolder();
    if (myPhotosRoot == null) {
      generateMyPhotosFolder(imageArchiveSortables);
    } else {
      final allByFolder = groupBy<Sortable<ImageArchiveData>, String>(
          imageArchiveSortables, (s) => s.groupId);
      final allById = {for (var s in imageArchiveSortables) s.id: s};
      yield MyPhotosState(
        allByFolder: allByFolder,
        allById: allById,
        currentFolderId: myPhotosRoot.id,
      );
    }
  }

  Stream<MyPhotosState> _mapPhotoAddedtoState(PhotoAdded event) async* {
    final sortablesState = sortableBloc.state;
    if (sortablesState is SortablesLoaded) {
      final imageArchiveSortables =
          sortablesState.sortables.whereType<Sortable<ImageArchiveData>>();
      final myPhotosFolder = imageArchiveSortables.getMyPhotosFolder() ??
          generateMyPhotosFolder(imageArchiveSortables);
      final sortableData = ImageArchiveData(
        name: event.name,
        file: '${FileStorage.folder}/${event.imageId}',
        fileId: event.imageId,
      );
      final myPhotosFolderContent = sortablesState.sortables
          .where((s) => s.groupId == myPhotosFolder.id)
          .toList();
      myPhotosFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = myPhotosFolderContent.isEmpty
          ? getStartSortOrder()
          : calculateNextSortOrder(myPhotosFolderContent.last.sortOrder, 1);
      final newSortable = Sortable.createNew<ImageArchiveData>(
        data: sortableData,
        groupId: myPhotosFolder.id,
        sortOrder: sortOrder,
      );
      sortableBloc.add(SortableUpdated(newSortable));
    }
  }

  Sortable<ImageArchiveData> generateMyPhotosFolder(
      Iterable<Sortable<ImageArchiveData>> sortables) {
    final sortOrder = sortables.firstSortOrderInFolder(null);

    final sortableData = ImageArchiveData(
      name: '',
      icon: '',
      myPhotos: true,
    );

    final myPhotos = Sortable.createNew<ImageArchiveData>(
      data: sortableData,
      groupId: null,
      isGroup: true,
      sortOrder: sortOrder,
    );

    sortableBloc.add(SortableUpdated(myPhotos));
    return myPhotos;
  }

  @override
  Future<void> close() async {
    if (sortableSubscription != null) {
      await sortableSubscription.cancel();
    }
    return super.close();
  }
}
