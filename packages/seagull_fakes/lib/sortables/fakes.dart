import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';
import 'package:sortables/sortables.dart';

class FakeSortableBloc extends Fake implements SortableBloc {
  @override
  Stream<SortableState> get stream => const Stream.empty();

  @override
  SortableState get state => SortablesNotLoaded();

  @override
  Future<void> close() async {}
}

class FakeSortableRepository extends Fake implements SortableRepository {}

class MockSortableRepository extends Mock implements SortableRepository {}

class FakeSortableDb extends Fake implements SortableDb {
  @override
  Future<Iterable<Sortable<SortableData>>> getAllNonDeleted() =>
      Future.value(defaultSortables);

  @override
  Future<bool> insertAndAddDirty(Iterable<Sortable> data) => Future.value(true);

  @override
  Future<Iterable<DbModel<Sortable>>> getAllDirty() =>
      Future.value(<DbModel<Sortable>>[]);

  @override
  Future<int> getLastRevision() => Future.value(0);

  @override
  Future<int> countAllDirty() => Future.value(0);
}
