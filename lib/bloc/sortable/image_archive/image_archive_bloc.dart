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
  ImageArchiveState get initialState => ImageArchiveState(Map(), null, null);

  @override
  Stream<ImageArchiveState> mapEventToState(
    ImageArchiveEvent event,
  ) async* {
    if (event is FolderChanged) {
      yield ImageArchiveState(state.all, event.folderId, state.selected);
    } else if (event is ArchiveImageSelected) {
      yield ImageArchiveState(state.all, state.currentFolder, event.imageId);
    } else if (event is SortablesUpdated) {
      final all = groupBy<Sortable, String>(event.sortables, (s) => s.groupId);
      // TODO check if current folder and selected image is still present among updated sortables
      yield ImageArchiveState(all, state.currentFolder, state.selected);
    }
  }
}
