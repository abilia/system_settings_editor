import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'slide_show_state.dart';

class SlideShowCubit extends Cubit<SlideShowState> {
  final SortableBloc sortableBloc;
  late final StreamSubscription sortableSubscription;
  late final Timer timer;
  final Duration slideDuration;

  SlideShowCubit({
    required this.sortableBloc,
    this.slideDuration = const Duration(minutes: 5),
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
    if (state.slideShowFolderContent.isEmpty) {
      emit(SlideShowState.empty());
    } else {
      final nextIndex =
          (state.currentIndex + 1) % state.slideShowFolderContent.length;
      emit(SlideShowState(
        currentIndex: nextIndex,
        slideShowFolderContent: state.slideShowFolderContent,
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
    final myPhotosFolder = sortables.getMyPhotosFolder();
    if (myPhotosFolder == null) {
      return SlideShowState.empty();
    }
    final imageArchiveSortables =
        sortables.whereType<Sortable<ImageArchiveData>>();
    final allByFolder = groupBy<Sortable<ImageArchiveData>, String>(
        imageArchiveSortables, (s) => s.groupId);
    final myPhotoFolder = allByFolder[myPhotosFolder.id];
    final allInMyPhotosRoot = [
      if (myPhotoFolder != null) ...myPhotoFolder.where((e) => !e.isGroup)
    ];
    return SlideShowState(
      currentIndex: 0,
      slideShowFolderContent: allInMyPhotosRoot..shuffle(),
    );
  }

  @override
  Future<void> close() async {
    timer.cancel();
    await sortableSubscription.cancel();
    return super.close();
  }
}
