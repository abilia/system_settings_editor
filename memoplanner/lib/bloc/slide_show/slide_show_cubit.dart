import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'slide_show_state.dart';

class SlideShowCubit extends Cubit<SlideShowState> {
  final SortableBloc sortableBloc;
  late final StreamSubscription _sortableSubscription;
  late Timer _timer;
  final Duration slideDuration;

  SlideShowCubit({
    required this.sortableBloc,
    this.slideDuration = const Duration(minutes: 5),
  }) : super(sortableStateToState(sortableBloc.state)) {
    _sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        sortablesUpdated(sortableState.sortables);
      }
    });
    _timer = Timer(slideDuration, () => next());
  }

  void sortablesUpdated(Iterable<Sortable> sortables) {
    emit(sortablesToState(sortables));
  }

  void next() {
    _timer.cancel();
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
    _timer = Timer(slideDuration, () => next());
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

    final allPhotoCalendarPhotos = [
      ...sortables
          .whereType<Sortable<ImageArchiveData>>()
          .where((e) => e.data.isInPhotoCalendar())
    ];
    return SlideShowState(
      currentIndex: 0,
      slideShowFolderContent: allPhotoCalendarPhotos..shuffle(),
    );
  }

  @override
  Future<void> close() async {
    _timer.cancel();
    await _sortableSubscription.cancel();
    return super.close();
  }
}
