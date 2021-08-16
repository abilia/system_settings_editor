part of 'my_photos_bloc.dart';

class MyPhotosState extends Equatable {
  final Map<String, Iterable<Sortable<ImageArchiveData>>> allByFolder;
  final Map<String, Sortable<ImageArchiveData>> allById;
  final String? currentFolderId;

  const MyPhotosState({
    this.allByFolder = const {},
    this.allById = const {},
    this.currentFolderId,
  });

  Iterable<Sortable<ImageArchiveData>> get currentFolderContent =>
      allByFolder[currentFolderId] ?? [];

  @override
  List<Object?> get props => [
        allByFolder,
        allById,
        currentFolderId,
      ];
}
