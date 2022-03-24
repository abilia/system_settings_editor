import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/sortable/reorder_sortables_cubit.dart';
import 'package:seagull/bloc/sortable/sortable_bloc.dart';
import 'package:seagull/models/sortable/sortable.dart';
import 'package:seagull/ui/all.dart';

import '../../mocks/mock_bloc.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';

  late SortableBloc mockSortableBloc;
  late List<Sortable> sortables;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.state).thenReturn(SortablesNotLoaded());
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());

    sortables = [
      Sortable.createNew<BasicActivityDataItem>(
        data: BasicActivityDataItem.createNew(title: activityNameOne),
      ),
      Sortable.createNew<BasicActivityDataItem>(
        data: BasicActivityDataItem.createNew(title: activityNameTwo),
      ),
      Sortable.createNew<BasicActivityDataItem>(
        isGroup: true,
        data: BasicActivityDataItem.createNew(title: 'Folder'),
      ),
      Sortable.createNew<BasicTimerDataItem>(
        data: BasicTimerDataItem.fromJson(
            '{"duration":60000,"title":"Basic Timer"}'),
      ),
    ];
  });

  blocTest(
    'cubit setup',
    build: () => ReorderSortablesCubit(mockSortableBloc),
    verify: (ReorderSortablesCubit bloc) => expect(
      bloc.state,
      -1,
    ),
  );

  group('reorder', () {
    test('first down', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emits(1),
      );

      cubit.reorder(sortables, sortables.first, SortableReorderDirection.down);

      await expected;
    });

    test('first up, no change', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emits(0),
      );

      cubit.reorder(sortables, sortables.first, SortableReorderDirection.up);

      await expected;
    });

    test('second down', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emits(2),
      );

      cubit.reorder(sortables, sortables.first, SortableReorderDirection.down);

      await expected;
    });

    test('second up', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emits(0),
      );

      cubit.reorder(sortables, sortables[1], SortableReorderDirection.up);

      await expected;
    });
  });

  group('select ', () {
    test('first', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emits(0),
      );

      cubit.select(0);

      await expected;
    });

    test('second, then first', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emitsInOrder([1, 0]),
      );

      cubit.select(1);

      cubit.select(0);

      await expected;
    });

    test('second twice deselects', () async {
      ReorderSortablesCubit cubit = ReorderSortablesCubit(mockSortableBloc);

      final expected = expectLater(
        cubit.stream,
        emitsInOrder([1, -1]),
      );

      cubit.select(1);

      cubit.select(1);

      await expected;
    });
  });
}
