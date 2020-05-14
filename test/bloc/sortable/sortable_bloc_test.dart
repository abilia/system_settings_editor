import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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
        pushBloc: MockPushBloc(),
        syncBloc: MockSyncBloc(),
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
          SortablesLoaded(sortables: []),
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

    test('Generates new imagearchive sortable with existing upload folder',
        () async {
      // Arrange
      final uploadFolder = Sortable.createNew(
        type: SortableType.imageArchive,
        isGroup: true,
        sortOrder: 'A',
        data: '{"upload": true}',
      );
      when(mockSortableRepository.load())
          .thenAnswer((_) => Future.value([uploadFolder]));
      final imageId = 'id1';
      final imageName = 'nameOfImage';
      final imagePath = 'path/to/image/$imageName.jpg';

      // Act
      sortableBloc.add(LoadSortables());
      sortableBloc.add(ImageArchiveImageAdded('id1', imagePath));

      // Assert
      await expectLater(
        sortableBloc,
        emitsInOrder([
          SortablesNotLoaded(),
          SortablesLoaded(sortables: [uploadFolder]),
          isA<SortablesLoaded>(),
        ]),
      );
      final capture =
          verify(mockSortableRepository.save(captureAny)).captured.single;
      final savedSortable = (capture as List<Sortable>).first;
      expect(savedSortable.groupId, uploadFolder.id);
      final jsonData = jsonDecode(savedSortable.data);
      expect(jsonData['name'], imageName);
      expect(jsonData['fileId'], imageId);
    });
  });
}
