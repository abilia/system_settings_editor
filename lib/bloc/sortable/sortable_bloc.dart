import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/sortable_repository.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  final SortableRepository sortableRepository;

  SortableBloc({
    @required this.sortableRepository,
  });

  @override
  SortableState get initialState => SortablesNotLoaded();

  @override
  Stream<SortableState> mapEventToState(
    SortableEvent event,
  ) async* {
    if (event is LoadSortables) {
      yield* _mapLoadSortablesToState();
    }
  }

  Stream<SortableState> _mapLoadSortablesToState() async* {
    try {
      final sortables = await sortableRepository.load();
      yield SortablesLoaded(sortables);
    } catch (_) {
      yield SortablesLoadedFailed();
    }
  }
}
