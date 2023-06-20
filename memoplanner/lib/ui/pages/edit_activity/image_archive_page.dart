import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  final VoidCallback? onCancel;
  final String initialFolder;
  final String? header;
  final SearchHeader searchHeader;
  final bool useHeader;

  const ImageArchivePage({
    Key? key,
    this.onCancel,
    this.initialFolder = '',
    this.header,
    this.searchHeader = SearchHeader.searchButton,
    this.useHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return LibraryPage<ImageArchiveData>.selectable(
      appBarTitle: translate.imageArchive,
      searchHeader: searchHeader,
      gridChildAspectRatio: layout.imageArchive.aspectRatio,
      rootHeading: header ?? translate.imageArchive,
      useHeader: useHeader,
      libraryItemGenerator: (imageArchive) =>
          ArchiveImage(sortable: imageArchive),
      selectedItemGenerator: (imageArchive) =>
          FullScreenArchiveImage(selected: imageArchive.data),
      emptyLibraryMessage: translate.noImages,
      onCancel: onCancel,
      onOk: (selected) {
        Navigator.of(context).pop<SelectedImageData>(
          SelectedImageData(
            imageAndName: ImageAndName(
              selected.data.name,
              AbiliaFile.from(
                id: selected.data.fileId,
                path: selected.data.file,
              ),
            ),
            fromSearch: searchHeader == SearchHeader.searchBar,
          ),
        );
      },
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;

  const ArchiveImage({
    required this.sortable,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageArchiveData = sortable.data;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    return LibraryImage(
      name: name,
      isImage: imageId.isNotEmpty || imageArchiveData.file.isNotEmpty,
      imageId: imageId,
      iconPath: iconPath,
    );
  }
}

class FullScreenArchiveImage extends StatelessWidget {
  const FullScreenArchiveImage({
    required this.selected,
    Key? key,
  }) : super(key: key);
  final ImageArchiveData selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(layout.imageArchive.fullscreenImagePadding),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: FullScreenImage(
          backgroundDecoration: whiteNoBorderBoxDecoration,
          fileId: selected.fileId,
          filePath: selected.file,
        ),
      ),
    );
  }
}
