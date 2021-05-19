part of 'slide_show_cubit.dart';

class SlideShowState extends Equatable {
  final List<Sortable<ImageArchiveData>> slideShowFolderContent;
  final int currentIndex;

  Sortable<ImageArchiveData> get currentImageArchiveData =>
      slideShowFolderContent.isNotEmpty
          ? slideShowFolderContent[currentIndex]
          : null;

  SlideShowState({
    @required this.slideShowFolderContent,
    @required this.currentIndex,
  });

  factory SlideShowState.empty() {
    return SlideShowState(currentIndex: 0, slideShowFolderContent: []);
  }

  @override
  List<Object> get props => [
        slideShowFolderContent,
        currentIndex,
      ];
}
