import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/sortable_repository.dart';

import '../../mocks.dart';

void main() {
  group('Sortable bloc event order', () {
    SortableBloc sortableBloc;
    SortableRepository mockSortableRepository;

    setUp(() {
      mockSortableRepository = MockSortableRepository();
      sortableBloc = SortableBloc(
        sortableRepository: mockSortableRepository,
      );
    });

    test('Initial state is SortablesNotLoaded', () {
      expect(sortableBloc.initialState, SortablesNotLoaded());
    });

    test('Sortables loaded after successful loading of sortables', () async {
      when(mockSortableRepository.load()).thenAnswer((_) => Future.value([]));
      sortableBloc.add(LoadSortables());
      await expectLater(
        sortableBloc,
        emitsInOrder([
          SortablesNotLoaded(),
          SortablesLoaded([]),
        ]),
      );
    });

    test('State is SortablesLoadedFailed if repository fails to load',
        () async {
      when(mockSortableRepository.load()).thenThrow(Exception());
      sortableBloc.add(LoadSortables());
      await expectLater(
        sortableBloc,
        emitsInOrder([
          SortablesNotLoaded(),
          SortablesLoadedFailed(),
        ]),
      );
    });
  });
}
