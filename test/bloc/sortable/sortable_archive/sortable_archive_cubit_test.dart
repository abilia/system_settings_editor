import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

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
}
