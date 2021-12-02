part of 'my_photos_bloc.dart';

class MyPhotosState extends Equatable {
  final String? rootFolderId;

  const MyPhotosState({
    this.rootFolderId,
  });

  @override
  List<Object?> get props => [
        rootFolderId,
      ];
}
