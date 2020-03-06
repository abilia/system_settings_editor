part of 'image_archive_bloc.dart';

class ImageArchiveState extends Equatable {
  final Map<String, List<Sortable>> allByFolder;
  final Map<String, Sortable> allById;
  final String currentFolderId;
  final String selectedImageId;

  ImageArchiveState(this.allByFolder, this.allById, this.currentFolderId,
      this.selectedImageId);

  @override
  List<Object> get props =>
      [allByFolder, allById, currentFolderId, selectedImageId];

  @override
  String toString() =>
      'ImageArchiveState { allByFoldler: $allByFolder, allById: $allById, currentFolderId: $currentFolderId, selectedImageId: $selectedImageId }';
}
