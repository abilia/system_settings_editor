part of 'my_photos_bloc.dart';

class MyPhotosState extends Equatable {
  final String? rootFolderId;
  final String? currentFolderId;

  const MyPhotosState({
    this.rootFolderId,
    this.currentFolderId,
  });

  @override
  List<Object?> get props => [
        rootFolderId,
        currentFolderId,
      ];
}
