part of 'my_photos_bloc.dart';

class MyPhotosState extends Equatable {
  final Map<String, Iterable<Sortable<ImageArchiveData>>> allByFolder;
  final Map<String, Sortable<ImageArchiveData>> allById;
  final String currentFolderId;

  const MyPhotosState({
    @required this.allByFolder,
    @required this.allById,
    @required this.currentFolderId,
  });

  List<Sortable<ImageArchiveData>> get currentFolderContent =>
      allByFolder.containsKey(currentFolderId)
          ? allByFolder[currentFolderId]
          : [];

  @override
  List<Object> get props => [
        allByFolder,
        allById,
        currentFolderId,
      ];
}
