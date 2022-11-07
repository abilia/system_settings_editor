import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import '../../../fakes/fakes_blocs.dart';

void main() {
  late SortableArchiveCubit<ImageArchiveData> imageArchiveBloc;

  setUp(() {
    imageArchiveBloc = SortableArchiveCubit<ImageArchiveData>(
      sortableBloc: FakeSortableBloc(),
    );
  });

  test('Initial state is an empty ImageArchiveState', () {
    expect(imageArchiveBloc.state,
        const SortableArchiveState<ImageArchiveData>({}, {}));
  });

  test('FolderChanged will set the folder in the state', () async {
    const folderId = '123';
    final expect = expectLater(
      imageArchiveBloc.stream,
      emits(const SortableArchiveState<ImageArchiveData>({}, {},
          currentFolderId: folderId)),
    );
    imageArchiveBloc.folderChanged(folderId);

    await expect;
  });

  test('SortablesUpdated will set the sortables in the state', () async {
    final imageArchiveSortable =
        Sortable.createNew(data: const ImageArchiveData());
    final checklistSortable =
        Sortable.createNew(data: ChecklistData(Checklist()));
    final expect = expectLater(
      imageArchiveBloc.stream,
      emits(stateFromSortables([imageArchiveSortable])),
    );
    imageArchiveBloc
        .sortablesUpdated([imageArchiveSortable, checklistSortable]);
    await expect;
  });

  test('NavigateUp will set the parent of the current folder as current folder',
      () async {
    final imageArchiveFolder1 = Sortable.createNew<ImageArchiveData>(
      data: const ImageArchiveData(),
      isGroup: true,
    );
    final imageArchiveFolder2 = Sortable.createNew<ImageArchiveData>(
      data: const ImageArchiveData(),
      isGroup: true,
      groupId: imageArchiveFolder1.id,
    );
    final expect = expectLater(
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
    imageArchiveBloc
        .sortablesUpdated([imageArchiveFolder1, imageArchiveFolder2]);
    imageArchiveBloc.folderChanged(imageArchiveFolder2.id);
    imageArchiveBloc.navigateUp();
    await expect;
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
