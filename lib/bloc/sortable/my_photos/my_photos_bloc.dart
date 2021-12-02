import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/sortable/sortable.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'my_photos_state.dart';
part 'my_photos_event.dart';

class MyPhotosBloc extends Bloc<MyPhotosEvent, MyPhotosState> {
  late final StreamSubscription sortableSubscription;
  final SortableBloc sortableBloc;
  MyPhotosBloc({required this.sortableBloc}) : super(const MyPhotosState()) {
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
    if (myPhotosRoot == null) return;

    yield MyPhotosState(
      rootFolderId: myPhotosRoot.id,
    );
  }

  Stream<MyPhotosState> _mapPhotoAddedtoState(PhotoAdded event) async* {
    final sortablesState = sortableBloc.state;
    if (sortablesState is SortablesLoaded) {
      final imageArchiveSortables =
          sortablesState.sortables.whereType<Sortable<ImageArchiveData>>();

      final folderId =
          event.folderId ?? imageArchiveSortables.getMyPhotosFolder()?.id;
      if (folderId == null) return;

      final sortableData = ImageArchiveData(
        name: event.name,
        file: '${FileStorage.folder}/${event.imageId}',
        fileId: event.imageId,
      );
      final folderContent =
          sortablesState.sortables.where((s) => s.groupId == folderId).toList();
      folderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = folderContent.isEmpty
          ? startSordOrder
          : calculateNextSortOrder(folderContent.last.sortOrder, 1);
      final newSortable = Sortable.createNew<ImageArchiveData>(
        data: sortableData,
        groupId: folderId,
        sortOrder: sortOrder,
      );
      sortableBloc.add(SortableUpdated(newSortable));
    }
  }

  @override
  Future<void> close() async {
    await sortableSubscription.cancel();
    return super.close();
  }
}
