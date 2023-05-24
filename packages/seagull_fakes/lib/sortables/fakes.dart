import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:sortables/all.dart';

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => const Stream.empty();

  @override
  SortableState get state => SortablesNotLoaded();

  @override
  Future<void> close() async {}
}

class MockDataRepository extends Mock implements DataRepository {}
