// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/data_repository/sortable_repository.dart';

import '../../mocks.dart';

void main() {
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
    expect(sortableBloc.state, SortablesNotLoaded());
  });

  test('Sortables loaded after successful loading of sortables', () async {
    when(mockSortableRepository.load()).thenAnswer((_) => Future.value([]));
    sortableBloc.add(LoadSortables());
    await expectLater(
      sortableBloc.stream,
      emits(SortablesLoaded(sortables: [])),
    );
  });

  test('State is SortablesLoadedFailed if repository fails to load', () async {
    when(mockSortableRepository.load()).thenThrow(Exception());
    sortableBloc.add(LoadSortables());
    await expectLater(
      sortableBloc.stream,
      emits(SortablesLoadedFailed()),
    );
  });

  test('Defaults are created for MP', () async {
    when(mockSortableRepository.load()).thenAnswer((_) => Future.value([]));
    sortableBloc.add(LoadSortables(initDefaults: true));
    await expectLater(
      sortableBloc.stream,
      emits(isA<SortablesLoaded>()),
    );
    final capture = verify(mockSortableRepository.save(captureAny)).captured;
    expect(capture.length, 2);

    final savedMyPhotos = (capture.first as List<Sortable<SortableData>>).first;
    expect((savedMyPhotos.data as ImageArchiveData).myPhotos, isTrue);

    final savedUpload = (capture.last as List<Sortable<SortableData>>).first;
    expect((savedUpload.data as ImageArchiveData).upload, isTrue);
  }, skip: !Config.isMP);

  test('Defaults are created for MPGO', () async {
    when(mockSortableRepository.load()).thenAnswer((_) => Future.value([]));
    sortableBloc.add(LoadSortables(initDefaults: true));
    await expectLater(
      sortableBloc.stream,
      emits(isA<SortablesLoaded>()),
    );
    final capture = verify(mockSortableRepository.save(captureAny)).captured;
    expect(capture.length, 1);

    final savedUpload = (capture.first as List<Sortable<SortableData>>).first;
    expect((savedUpload.data as ImageArchiveData).upload, isTrue);
  }, skip: Config.isMP);

  test('Generates new imagearchive sortable with existing upload folder',
      () async {
    // Arrange
    final uploadFolder = Sortable.createNew<ImageArchiveData>(
      isGroup: true,
      sortOrder: 'A',
      data: ImageArchiveData.fromJson('{"upload": true}'),
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
      sortableBloc.stream,
      emitsInOrder([
        SortablesLoaded(sortables: [uploadFolder]),
        isA<SortablesLoaded>(),
      ]),
    );
    final capture =
        verify(mockSortableRepository.save(captureAny)).captured.single;
    final savedSortable = (capture as List<Sortable>).first;
    expect(savedSortable.groupId, uploadFolder.id);
    expect(savedSortable, isA<Sortable<ImageArchiveData>>());
    final savedImageArchiveData = savedSortable as Sortable<ImageArchiveData>;
    expect(savedImageArchiveData.data.name, imageName);
    expect(savedImageArchiveData.data.fileId, imageId);
  });
}
