part of 'image_archive_bloc.dart';

class ImageArchiveState extends Equatable {
  final Map<String, Iterable<Sortable<ImageArchiveData>>> allByFolder;
  final Map<String, Sortable<ImageArchiveData>> allById;
  final String currentFolderId;

  ImageArchiveState(
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
