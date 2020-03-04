part of 'image_archive_bloc.dart';

class ImageArchiveState {
  final Map<String, List<Sortable>> all;
  final String currentFolder;
  final String selected;

  ImageArchiveState(this.all, this.currentFolder, this.selected);
}
