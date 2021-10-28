part of 'slide_show_cubit.dart';

class SlideShowState extends Equatable {
  final List<Sortable<ImageArchiveData>> slideShowFolderContent;
  final int currentIndex;

  String? get currentFileId => slideShowFolderContent.isNotEmpty
      ? slideShowFolderContent[currentIndex].data.fileId
      : null;

  String? get currentPath => slideShowFolderContent.isNotEmpty
      ? slideShowFolderContent[currentIndex].data.file
      : null;

  const SlideShowState({
    required this.slideShowFolderContent,
    required this.currentIndex,
  });

  factory SlideShowState.empty() {
    return const SlideShowState(currentIndex: 0, slideShowFolderContent: []);
  }

  @override
  List<Object> get props => [
        slideShowFolderContent,
        currentIndex,
      ];
}
