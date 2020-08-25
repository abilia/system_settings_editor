part of 'image_archive_bloc.dart';

class SortableArchiveState<T extends SortableData> extends Equatable {
  final Map<String, Iterable<Sortable<T>>> allByFolder;
  final Map<String, Sortable<T>> allById;
  final String currentFolderId;

  SortableArchiveState(
    this.allByFolder,
    this.allById,
    this.currentFolderId,
  );

  @override
  List<Object> get props => [
        allByFolder,
        allById,
        currentFolderId,
      ];

  @override
  bool get stringify => true;
}
