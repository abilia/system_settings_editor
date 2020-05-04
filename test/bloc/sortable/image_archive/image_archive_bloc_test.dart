import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sortable/image_archive/bloc.dart';
import 'package:seagull/models/all.dart';

import '../../../mocks.dart';
import '../../../ui/components/sortable/image_archive_test.dart';

void main() {
  group('ImageArchiveBloc event order', () {
    ImageArchiveBloc imageArchiveBloc;
    SortableBloc sortableBlocMock;

    setUp(() {
      sortableBlocMock = MockSortableBloc();
      imageArchiveBloc = ImageArchiveBloc(
        sortableBloc: sortableBlocMock,
      );
    });

    test('Initial state is an empty ImageArchiveState', () {
      expect(imageArchiveBloc.initialState,
          ImageArchiveState(Map(), Map(), null, null));
    });

    test('FolderChanged will set the folder in the state', () async {
      String folderId = '123';
      imageArchiveBloc.add(FolderChanged(folderId));
      await expectLater(
        imageArchiveBloc,
        emitsInOrder([
          ImageArchiveState(Map(), Map(), null, null),
          ImageArchiveState(Map(), Map(), folderId, null),
        ]),
      );
    });

    test('ArchiveImageSelected will set the selected image in the state',
        () async {
      final imageData = SortableData(fileId: '123');
      imageArchiveBloc.add(ArchiveImageSelected(imageData));
      await expectLater(
        imageArchiveBloc,
        emitsInOrder([
          ImageArchiveState(Map(), Map(), null, null),
          ImageArchiveState(Map(), Map(), null, imageData),
        ]),
      );
    });

    test('SortablesUpdated will set the sortables in the state', () async {
      Sortable imageArchiveSortable =
          Sortable.createNew(type: SortableType.imageArchive);
      Sortable checklistSortable =
          Sortable.createNew(type: SortableType.checklist);
      imageArchiveBloc
          .add(SortablesUpdated([imageArchiveSortable, checklistSortable]));
      await expectLater(
        imageArchiveBloc,
        emitsInOrder([
          ImageArchiveState(Map(), Map(), null, null),
          stateFromSortables([imageArchiveSortable]),
        ]),
      );
    });

    test(
        'NavigateUp will set the parent of the current folder as current folder',
        () async {
      Sortable imageArchiveFolder1 = Sortable.createNew(
        type: SortableType.imageArchive,
        isGroup: true,
      );
      Sortable imageArchiveFolder2 = Sortable.createNew(
          type: SortableType.imageArchive,
          isGroup: true,
          groupId: imageArchiveFolder1.id);
      imageArchiveBloc
          .add(SortablesUpdated([imageArchiveFolder1, imageArchiveFolder2]));
      imageArchiveBloc.add(FolderChanged(imageArchiveFolder2.id));
      imageArchiveBloc.add(NavigateUp());
      await expectLater(
        imageArchiveBloc,
        emitsInOrder([
          ImageArchiveState(Map(), Map(), null, null),
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
  });
}
