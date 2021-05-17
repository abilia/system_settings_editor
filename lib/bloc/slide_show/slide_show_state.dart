part of 'slide_show_cubit.dart';

class SlideShowState extends Equatable {
  final List<String> fileIds;
  final String currentFileId;
  final int currentFileIndex;

  SlideShowState({
    @required this.fileIds,
    @required this.currentFileId,
    @required this.currentFileIndex,
  });

  factory SlideShowState.empty() {
    return SlideShowState(
        currentFileId: null, currentFileIndex: 0, fileIds: []);
  }

  @override
  List<Object> get props => [
        fileIds,
        currentFileId,
        currentFileIndex,
      ];
}
