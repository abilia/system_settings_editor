import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  final SearchHeader searchHeader;

  const ImageArchivePage({
    Key? key,
    this.searchHeader = SearchHeader.searchButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final sortableArchiveCubit =
        context.watch<SortableArchiveCubit<ImageArchiveData>>();
    final sortableState = sortableArchiveCubit.state;
    final selected = sortableState.isSelected;
    return LibraryPage<ImageArchiveData>.selectable(
      searchHeader: searchHeader,
      gridChildAspectRatio: layout.imageArchive.aspectRatio,
      useHeader: false,
      appBar: AbiliaAppBar(
        iconData: searchHeader == SearchHeader.searchBar
            ? AbiliaIcons.find
            : AbiliaIcons.pastPictureFromWindowsClipboard,
        label: searchHeader == SearchHeader.searchBar
            ? null
            : selected
                ? sortableState.selected?.data.name
                : sortableState.isAtRoot
                    ? translate.imageArchive
                    : '${translate.imageArchive} / ${sortableState.breadCrumbPath()}',
        title: searchHeader == SearchHeader.searchBar
            ? translate.searchImage
            : translate.selectImage,
        trailing: !selected && searchHeader == SearchHeader.searchButton
            ? Padding(
                padding:
                    EdgeInsets.only(right: layout.actionButton.padding.right),
                child: SearchButton(
                  style: actionButtonStyleLightLarge,
                ),
              )
            : null,
        isFlipLabels: true,
      ),
      libraryItemGenerator: (imageArchive) =>
          ArchiveImage(sortable: imageArchive),
      selectedItemGenerator: (imageArchive) =>
          FullScreenArchiveImage(selected: imageArchive.data),
      emptyLibraryMessage: translate.noImages,
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
