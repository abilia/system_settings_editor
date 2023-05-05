import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late SortableBloc mockSortableBloc;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.state).thenReturn(SortablesNotLoaded());
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  blocTest(
    'initial folder is empty if no initial is specified',
    build: () =>
        SortableArchiveCubit<RawSortableData>(sortableBloc: mockSortableBloc),
    verify: (SortableArchiveCubit bloc) => expect(
      bloc.state,
      const SortableArchiveState<RawSortableData>([]),
    ),
  );

  blocTest(
    'initial and current folder is specified folder',
    build: () => SortableArchiveCubit<RawSortableData>(
      sortableBloc: mockSortableBloc,
      initialFolderId: 'someFolderId',
    ),
    verify: (SortableArchiveCubit bloc) => expect(
      bloc.state,
      const SortableArchiveState<RawSortableData>(
        [],
        initialFolderId: 'someFolderId',
        currentFolderId: 'someFolderId',
      ),
    ),
  );

  group('sorting and selecting', () {
    const String activityNameOne = 'Basic Activity 1';
    const String activityNameTwo = 'Basic Activity 2';

    late SortableBloc mockSortableBloc;
    final first = Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: activityNameOne),
            sortOrder: 'a'),
        second = Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: activityNameTwo),
            sortOrder: 'b'),
        third = Sortable.createNew<BasicActivityDataItem>(
            isGroup: true,
            data: BasicActivityDataItem.createNew(title: 'Folder'),
            sortOrder: 'c');
    final timer = Sortable.createNew<BasicTimerDataItem>(
      data: BasicTimerDataItem.fromJson(
          '{"duration":60000,"title":"Basic Timer"}'),
    );
    final List<Sortable> basicActivitySortables = [first, second, third];
    final List<Sortable> sortables = [...basicActivitySortables, timer];

    setUp(() {
      mockSortableBloc = MockSortableBloc();
      when(() => mockSortableBloc.state)
          .thenReturn(SortablesLoaded(sortables: sortables));
      when(() => mockSortableBloc.stream).thenAnswer(
          (_) => Stream.value(SortablesLoaded(sortables: sortables)));
    });

    group('reorder', () {
      test('first down', () {
        SortableArchiveCubit<BasicActivityData>(sortableBloc: mockSortableBloc)
          ..sortableSelected(first)
          ..reorder(SortableReorderDirection.down);

        final captured =
            verify(() => mockSortableBloc.add(captureAny())).captured.first;
        expect(captured, isInstanceOf<SortablesUpdated>());
        expect(
          (captured as SortablesUpdated).sortables,
          unorderedEquals(
            [
              first.copyWith(sortOrder: second.sortOrder),
              second.copyWith(sortOrder: first.sortOrder),
            ],
          ),
        );
      });

      test('first up, no change', () {
        SortableArchiveCubit<BasicActivityData>(sortableBloc: mockSortableBloc)
          ..sortableSelected(first)
          ..reorder(SortableReorderDirection.up);

        verifyNever(() => mockSortableBloc.add(any()));
      });

      test('second down', () {
        SortableArchiveCubit<BasicActivityData>(sortableBloc: mockSortableBloc)
          ..sortableSelected(second)
          ..reorder(SortableReorderDirection.down);

        final captured =
            verify(() => mockSortableBloc.add(captureAny())).captured.first;
        expect(captured, isInstanceOf<SortablesUpdated>());
        expect(
          (captured as SortablesUpdated).sortables,
          unorderedEquals(
            [
              second.copyWith(sortOrder: third.sortOrder),
              third.copyWith(sortOrder: second.sortOrder),
            ],
          ),
        );
      });

      test('second up', () async {
        SortableArchiveCubit<BasicActivityData>(sortableBloc: mockSortableBloc)
          ..sortableSelected(second)
          ..reorder(SortableReorderDirection.up);

        final captured =
            verify(() => mockSortableBloc.add(captureAny())).captured.first;
        expect(captured, isInstanceOf<SortablesUpdated>());
        expect(
          (captured as SortablesUpdated).sortables,
          unorderedEquals(
            [
              second.copyWith(sortOrder: first.sortOrder),
              first.copyWith(sortOrder: second.sortOrder),
            ],
          ),
        );
      });
    });

    group('select ', () {
      blocTest<SortableArchiveCubit<BasicActivityDataItem>,
          SortableArchiveState<BasicActivityDataItem>>(
        'first',
        build: () => SortableArchiveCubit<BasicActivityDataItem>(
            sortableBloc: mockSortableBloc),
        act: (c) => c.sortableSelected(first),
        expect: () => [
          SortableArchiveState.fromSortables(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolders: true,
            selected: first,
            myPhotos: false,
          )
        ],
      );

      blocTest<SortableArchiveCubit<BasicActivityDataItem>,
          SortableArchiveState<BasicActivityDataItem>>(
        'second, then first',
        build: () => SortableArchiveCubit<BasicActivityDataItem>(
            sortableBloc: mockSortableBloc),
        act: (c) => c
          ..sortableSelected(second)
          ..sortableSelected(first),
        expect: () => [
          SortableArchiveState.fromSortables(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolders: true,
            selected: second,
            myPhotos: false,
          ),
          SortableArchiveState.fromSortables(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolders: true,
            selected: first,
            myPhotos: false,
          )
        ],
      );
    });
  });

  group('Image archive search', () {
    late SortableArchiveCubit<ImageArchiveData> sortableArchiveCubit;
    final first = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(name: 'first'),
          sortOrder: 'a',
        ),
        second = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(name: 'second'),
          sortOrder: 'a',
        ),
        third = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(name: 'third'),
          sortOrder: 'a',
        );
    final List<Sortable> basicActivitySortables = [first, second, third];

    setUp(() {
      sortableArchiveCubit = SortableArchiveCubit<ImageArchiveData>(
        sortableBloc: mockSortableBloc,
      );
    });

    blocTest<SortableArchiveCubit<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      'Search full word',
      build: () => sortableArchiveCubit,
      act: (cubit) => cubit
        ..sortablesUpdated(basicActivitySortables)
        ..searchValueChanged('first'),
      verify: (_) {
        expect(sortableArchiveCubit.state.allFilteredAndSorted(),
            [first]);
      },
    );

    blocTest<SortableArchiveCubit<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      'Search single letter',
      build: () => sortableArchiveCubit,
      act: (cubit) => cubit
        ..sortablesUpdated(basicActivitySortables)
        ..searchValueChanged('i'),
      verify: (_) {
        expect(sortableArchiveCubit.state.allFilteredAndSorted(),
            [first, third]);
      },
    );

    blocTest<SortableArchiveCubit<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      'Search nothing',
      build: () => sortableArchiveCubit,
      act: (cubit) => cubit
        ..sortablesUpdated(basicActivitySortables)
        ..searchValueChanged(''),
      verify: (_) {
        expect(sortableArchiveCubit.state.allFilteredAndSorted(), []);
      },
    );

    blocTest<SortableArchiveCubit<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      'Search nonsense',
      build: () => sortableArchiveCubit,
      act: (cubit) => cubit
        ..sortablesUpdated(basicActivitySortables)
        ..searchValueChanged('T43Q87Y87yh78yh6'),
      verify: (_) {
        expect(sortableArchiveCubit.state.allFilteredAndSorted(), []);
      },
    );
  });
}
