import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/sortable/sortable_bloc.dart';
import 'package:seagull/models/sortable/sortable.dart';
import 'package:seagull/ui/components/activity/sortable_toolbar.dart';

class ReorderSortablesCubit extends Cubit<int> {
  ReorderSortablesCubit(this._sortableBloc) : super(-1);

  final SortableBloc _sortableBloc;

  void select(int selected) => emit(selected == state ? -1 : selected);

  void reorder(List<Sortable> sortables, final Sortable sortable,
      SortableReorderDirection direction) {
    final sortableIndex = sortables.indexWhere((q) => q.id == sortable.id);
    final swapWithIndex = direction == SortableReorderDirection.up
        ? sortableIndex - 1
        : sortableIndex + 1;
    if (sortableIndex >= 0 &&
        sortableIndex < sortables.length &&
        swapWithIndex >= 0 &&
        swapWithIndex < sortables.length) {
      final tmpQ = sortables[sortableIndex];
      sortables[sortableIndex] = sortables[swapWithIndex];
      sortables[swapWithIndex] = tmpQ;
      emit(swapWithIndex);
      _sortableBloc.add(SortablesUpdated(sortables));
    } else {
      emit(sortableIndex);
    }
  }
}
