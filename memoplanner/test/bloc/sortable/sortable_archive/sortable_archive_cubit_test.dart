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
      const SortableArchiveState<RawSortableData>({}, {}),
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
        {},
        {},
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
        final cubit = SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc);

        cubit.sortableSelected(first);
        cubit.reorder(SortableReorderDirection.down);

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
        final cubit = SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc);

        cubit.sortableSelected(first);
        cubit.reorder(SortableReorderDirection.up);

        verifyNever(() => mockSortableBloc.add(any()));
      });

      test('second down', () {
        final cubit = SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc);

        cubit.sortableSelected(second);
        cubit.reorder(SortableReorderDirection.down);

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
        final cubit = SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc);

        cubit.sortableSelected(second);
        cubit.reorder(SortableReorderDirection.up);

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
      blocTest<SortableArchiveCubit<BasicActivityData>,
          SortableArchiveState<BasicActivityData>>(
        'first',
        build: () => SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc),
        act: (c) => c.sortableSelected(first),
        expect: () => [
          SortableArchiveCubit.stateFromSortables<BasicActivityData>(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolder: true,
            selected: first,
          )
        ],
      );

      blocTest<SortableArchiveCubit<BasicActivityData>,
          SortableArchiveState<BasicActivityData>>(
        'second, then first',
        build: () => SortableArchiveCubit<BasicActivityData>(
            sortableBloc: mockSortableBloc),
        act: (c) {
          c.sortableSelected(second);
          c.sortableSelected(first);
        },
        expect: () => [
          SortableArchiveCubit.stateFromSortables<BasicActivityData>(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolder: true,
            selected: second,
          ),
          SortableArchiveCubit.stateFromSortables<BasicActivityData>(
            sortables: basicActivitySortables,
            initialFolderId: '',
            currentFolderId: '',
            showFolder: true,
            selected: first,
          )
        ],
      );
    });
  });
}
