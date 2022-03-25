import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/sortable/sortable_bloc.dart';
import 'package:seagull/models/sortable/sortable.dart';
import 'package:seagull/ui/components/activity/sortable_toolbar.dart';
import 'package:seagull/utils/all.dart';

class ReorderSortablesCubit extends Cubit<int> {
  ReorderSortablesCubit(this._sortableBloc) : super(-1);

  final SortableBloc _sortableBloc;

  void select(int selected) => emit(selected == state ? -1 : selected);

  void reorder(List<Sortable> sortables, final Sortable sortable,
      SortableReorderDirection direction) {
    final sortableIndex = sortables.indexWhere((s) => s.id == sortable.id);
    final swapWithIndex = direction == SortableReorderDirection.up
        ? sortableIndex - 1
        : sortableIndex + 1;
    if (sortableIndex >= 0 &&
        sortableIndex < sortables.length &&
        swapWithIndex >= 0 &&
        swapWithIndex < sortables.length) {
      final tempSortable = sortables[sortableIndex];
      sortables[sortableIndex] = sortables[swapWithIndex]
          .copyWith(sortOrder: sortables[sortableIndex].sortOrder);
      sortables[swapWithIndex] =
          tempSortable.copyWith(sortOrder: sortables[swapWithIndex].sortOrder);
      emit(swapWithIndex);
      _sortableBloc.add(SortablesUpdated(sortables));
    } else {
      emit(sortableIndex);
    }
  }

  void delete(List<Sortable> sortables, final Sortable sortable) {
    String sortOrder = '';
    int index = 0;
    for (var s in sortables) {
      sortables[index++] = s.copyWith(
          sortOrder: calculateNextSortOrder(sortOrder, 1),
          deleted: s.id == sortable.id ? true : false);
    }
    _sortableBloc.add(SortablesUpdated(sortables));
    emit(-1);
  }
}
