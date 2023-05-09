import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sortables/all.dart';

import '../fakes/fake_dummy_bloc.dart';
import '../mocks/mocks.dart';

void main() {
  late SortableBloc sortableBloc;
  late MockSortableRepository mockSortableRepository;

  setUp(() {
    mockSortableRepository = MockSortableRepository();
    sortableBloc = SortableBloc(
      sortableRepository: mockSortableRepository,
      syncBloc: FakeDummyBloc(),
      fileStorageFolder: 'seagull',
    );
  });

  test('Initial state is SortablesNotLoaded', () {
    expect(sortableBloc.state, SortablesNotLoaded());
  });

  test('Sortables loaded after successful loading of sortables', () async {
    when(() => mockSortableRepository.getAll())
        .thenAnswer((_) => Future.value([]));
    sortableBloc.add(const LoadSortables());
    await expectLater(
      sortableBloc.stream,
      emits(const SortablesLoaded(sortables: [])),
    );
  });

  test('State is SortablesLoadedFailed if repository fails to load', () async {
    when(() => mockSortableRepository.getAll()).thenThrow(Exception());
    sortableBloc.add(const LoadSortables());
    await expectLater(
      sortableBloc.stream,
      emits(SortablesLoadedFailed()),
    );
  });

  test('Defaults are created', () async {
    when(() => mockSortableRepository.getAll())
        .thenAnswer((_) => Future.value([]));
    when(() => mockSortableRepository.createUploadsFolder())
        .thenAnswer((_) => Future.value());
    when(() => mockSortableRepository.createMyPhotosFolder())
        .thenAnswer((_) => Future.value());
    when(() => mockSortableRepository.save(any()))
        .thenAnswer((_) => Future.value(true));
    sortableBloc.add(const LoadSortables(initDefaults: true));
    await expectLater(
      sortableBloc.stream,
      emits(isA<SortablesLoaded>()),
    );
    verify(() => mockSortableRepository.createUploadsFolder());
    verify(() => mockSortableRepository.createMyPhotosFolder());
  });

  test('Generates new imagearchive sortable with existing upload folder',
      () async {
    // Arrange
    final uploadFolder = Sortable.createNew<ImageArchiveData>(
      isGroup: true,
      fixed: true,
      sortOrder: 'A',
      data: const ImageArchiveData(upload: true),
    );
    when(() => mockSortableRepository.getAll())
        .thenAnswer((_) => Future.value([uploadFolder]));
    when(() => mockSortableRepository.save(any()))
        .thenAnswer((_) => Future.value(true));
    const imageId = 'id1';
    const imageName = 'nameOfImage';

    // Act
    sortableBloc
      ..add(const LoadSortables())
      ..add(const ImageArchiveImageAdded('id1', imageName));

    // Assert
    await expectLater(
      sortableBloc.stream,
      emitsInOrder([
        SortablesLoaded(sortables: [uploadFolder]),
        isA<SortablesLoaded>(),
      ]),
    );
    final capture =
        verify(() => mockSortableRepository.save(captureAny())).captured.single;
    final savedSortable = (capture as List<Sortable>).first;
    expect(savedSortable.groupId, uploadFolder.id);
    expect(savedSortable, isA<Sortable<ImageArchiveData>>());
    final savedImageArchiveData = savedSortable as Sortable<ImageArchiveData>;
    expect(savedImageArchiveData.data.name, imageName);
    expect(savedImageArchiveData.data.fileId, imageId);
  });
}
