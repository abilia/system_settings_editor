import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../mocks.dart';
import '../../../ui/components/sortable/image_archive_test.dart';

void main() {
  ImageArchiveBloc imageArchiveBloc;
  SortableBloc sortableBlocMock;

  setUp(() {
    sortableBlocMock = MockSortableBloc();
    imageArchiveBloc = ImageArchiveBloc(
      sortableBloc: sortableBlocMock,
    );
  });

  test('Initial state is an empty ImageArchiveState', () {
    expect(imageArchiveBloc.state, ImageArchiveState({}, {}, null));
  });

  test('FolderChanged will set the folder in the state', () async {
    final folderId = '123';
    imageArchiveBloc.add(FolderChanged(folderId));
    await expectLater(
      imageArchiveBloc,
      emits(ImageArchiveState({}, {}, folderId)),
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
      imageArchiveBloc,
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
      imageArchiveBloc,
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
