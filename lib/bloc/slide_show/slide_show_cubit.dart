import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

part 'slide_show_state.dart';

class SlideShowCubit extends Cubit<SlideShowState> {
  final SortableBloc sortableBloc;
  StreamSubscription sortableSubscription;
  Timer timer;
  final Duration slideDuration;

  SlideShowCubit({
    this.sortableBloc,
    this.slideDuration = const Duration(seconds: 30),
  }) : super(sortableStateToState(sortableBloc.state)) {
    sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        sortablesUpdated(sortableState.sortables);
      }
    });
    timer = Timer(slideDuration, () => next());
  }

  void sortablesUpdated(Iterable<Sortable> sortables) {
    final state = sortablesToState(sortables);
    emit(state);
  }

  void next() {
    timer.cancel();
    if (state.fileIds.isEmpty) {
      emit(SlideShowState.empty());
    } else {
      final nextIndex = (state.currentFileIndex + 1) % state.fileIds.length;
      emit(SlideShowState(
        currentFileId: state.fileIds[nextIndex],
        currentFileIndex: nextIndex,
        fileIds: state.fileIds,
      ));
    }
    timer = Timer(slideDuration, () => next());
  }

  static SlideShowState sortableStateToState(SortableState state) {
    if (state is SortablesLoaded) {
      return sortablesToState(state.sortables);
    } else {
      return SlideShowState.empty();
    }
  }

  static SlideShowState sortablesToState(Iterable<Sortable> sortables) {
    try {
      final uploadFolder = sortables.getUploadFolder();
      final imageArchiveSortables =
          sortables.whereType<Sortable<ImageArchiveData>>();
      final allByFolder = groupBy<Sortable<ImageArchiveData>, String>(
          imageArchiveSortables, (s) => s.groupId);
      final allInUploadFolder = allByFolder[uploadFolder.id];
      final allImageIds = allInUploadFolder.map((s) => s.data.fileId).toList();
      return SlideShowState(
        currentFileId: allImageIds.isNotEmpty ? allImageIds.first : null,
        currentFileIndex: 0,
        fileIds: allImageIds,
      );
    } catch (e) {
      return SlideShowState.empty();
    }
  }

  @override
  Future<void> close() async {
    timer?.cancel();
    return super.close();
  }
}
