import 'package:mocktail/mocktail.dart';
import 'package:sortables/bloc/sortable/sortable_bloc.dart';

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => const Stream.empty();

  @override
  SortableState get state => SortablesNotLoaded();

  @override
  Future<void> close() async {}
}
