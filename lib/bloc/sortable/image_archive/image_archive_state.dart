part of 'image_archive_bloc.dart';

class ImageArchiveState {
  final Map<String, List<Sortable>> allByFolder;
  final Map<String, Sortable> allById;
  final String currentFolderId;
  final String selectedImageId;

  ImageArchiveState(
      this.allByFolder, this.allById, this.currentFolderId, this.selectedImageId);
}
