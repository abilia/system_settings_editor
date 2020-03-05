import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'image_archive_event.dart';
part 'image_archive_state.dart';

class ImageArchiveBloc extends Bloc<ImageArchiveEvent, ImageArchiveState> {
  final SortableBloc sortableBloc;
  StreamSubscription sortableSubscription;

  ImageArchiveBloc({@required this.sortableBloc}) {
    sortableSubscription = sortableBloc.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        add(SortablesUpdated(sortableState.sortables.toList()));
      }
    });
    final sortableState = sortableBloc.state;
    if (sortableState is SortablesLoaded) {
      SortablesUpdated(sortableState.sortables.toList());
    }
  }

  @override
  ImageArchiveState get initialState =>
      ImageArchiveState(Map(), Map(), null, null);

  @override
  Stream<ImageArchiveState> mapEventToState(
    ImageArchiveEvent event,
  ) async* {
    if (event is FolderChanged) {
      yield ImageArchiveState(state.allByFolder, state.allById, event.folderId,
          state.selectedImageId);
    } else if (event is ArchiveImageSelected) {
      yield ImageArchiveState(state.allByFolder, state.allById,
          state.currentFolderId, event.imageId);
    } else if (event is SortablesUpdated) {
      final imageArchive =
          event.sortables.where((s) => s.type == 'imagearchive');
      final allByFolder =
          groupBy<Sortable, String>(imageArchive, (s) => s.groupId);
      final allById = Map<String, Sortable>.fromIterable(imageArchive,
          key: (s) => s.id, value: (s) => s);
      final selectedImage = allById[state.selectedImageId];
      final currentFolder = allById[state.currentFolderId];
      yield ImageArchiveState(
          allByFolder, allById, currentFolder?.id, selectedImage?.id);
    } else if (event is NavigateUp) {
      final currentFolder = state.allById[state.currentFolderId];
      yield ImageArchiveState(state.allByFolder, state.allById,
          currentFolder.groupId, state.selectedImageId);
    }
  }
}
