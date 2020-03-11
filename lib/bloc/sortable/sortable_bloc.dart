import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/sortable_repository.dart';

part 'sortable_event.dart';
part 'sortable_state.dart';

class SortableBloc extends Bloc<SortableEvent, SortableState> {
  final SortableRepository sortableRepository;
  StreamSubscription pushSubscription;

  SortableBloc({
    @required this.sortableRepository,
    @required PushBloc pushBloc,
  }) {
    pushSubscription = pushBloc.listen((state) {
      print('got push to sortable bloc with state: $state');
      if (state is PushReceived && state.pushType == PushType.sortable) {
        add(LoadSortables());
      }
    });
  }

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

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
