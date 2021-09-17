import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../fakes/fakes_blocs.dart';

void main() {
  late SortableArchiveBloc<ImageArchiveData> imageArchiveBloc;

  setUp(() {
    imageArchiveBloc = SortableArchiveBloc<ImageArchiveData>(
      sortableBloc: FakeSortableBloc(),
    );
  });

  test('Initial state is an empty ImageArchiveState', () {
    expect(
        imageArchiveBloc.state, SortableArchiveState<ImageArchiveData>({}, {}));
  });

  test('FolderChanged will set the folder in the state', () async {
    const folderId = '123';
    imageArchiveBloc.add(FolderChanged(folderId));
    await expectLater(
      imageArchiveBloc.stream,
      emits(SortableArchiveState<ImageArchiveData>({}, {},
          currentFolderId: folderId)),
    );
  });

  test('SortablesUpdated will set the sortables in the state', () async {
    final imageArchiveSortable =
        Sortable.createNew<ImageArchiveData>(data: ImageArchiveData());
    final checklistSortable =
        Sortable.createNew<RawSortableData>(data: RawSortableData(''));
    imageArchiveBloc
        .add(SortablesUpdated([imageArchiveSortable, checklistSortable]));
    await expectLater(
      imageArchiveBloc.stream,
      emits(stateFromSortables([imageArchiveSortable])),
    );
  });

  test('NavigateUp will set the parent of the current folder as current folder',
      () async {
    final imageArchiveFolder1 = Sortable.createNew<ImageArchiveData>(
      data: ImageArchiveData(),
      isGroup: true,
    );
    final imageArchiveFolder2 = Sortable.createNew<ImageArchiveData>(
      data: ImageArchiveData(),
      isGroup: true,
      groupId: imageArchiveFolder1.id,
    );
    imageArchiveBloc
        .add(SortablesUpdated([imageArchiveFolder1, imageArchiveFolder2]));
    imageArchiveBloc.add(FolderChanged(imageArchiveFolder2.id));
    imageArchiveBloc.add(NavigateUp());
    await expectLater(
      imageArchiveBloc.stream,
      emitsInOrder([
        stateFromSortables([imageArchiveFolder1, imageArchiveFolder2]),
        stateFromSortables(
          [imageArchiveFolder1, imageArchiveFolder2],
          folderId: imageArchiveFolder2.id,
        ),
        stateFromSortables(
          [imageArchiveFolder1, imageArchiveFolder2],
          folderId: imageArchiveFolder1.id,
        ),
      ]),
    );
  });
}

SortableArchiveState stateFromSortables(
  List<Sortable<ImageArchiveData>> sortables, {
  String folderId = '',
}) {
  final allByFolder =
      groupBy<Sortable<ImageArchiveData>, String>(sortables, (s) => s.groupId);
  final allById = {for (var s in sortables) s.id: s};
  return SortableArchiveState<ImageArchiveData>(allByFolder, allById,
      currentFolderId: folderId);
}
