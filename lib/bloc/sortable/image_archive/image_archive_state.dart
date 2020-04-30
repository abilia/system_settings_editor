part of 'image_archive_bloc.dart';

class ImageArchiveState extends Equatable {
  final Map<String, Iterable<Sortable>> allByFolder;
  final Map<String, Sortable> allById;
  final String currentFolderId;
  final SortableData selectedImageData;

  ImageArchiveState(this.allByFolder, this.allById, this.currentFolderId,
      this.selectedImageData);

  @override
  List<Object> get props =>
      [allByFolder, allById, currentFolderId, selectedImageData];

  @override
  String toString() =>
      'ImageArchiveState { allByFoldler: $allByFolder, allById: $allById, currentFolderId: $currentFolderId, selectedImageId: $selectedImageData }';
}
