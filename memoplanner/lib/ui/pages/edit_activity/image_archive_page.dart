import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  final SearchHeader searchHeader;

  const ImageArchivePage({
    super.key,
    this.searchHeader = SearchHeader.searchButton,
  });

  @override
  Widget build(BuildContext context) {
    return LibraryPage<ImageArchiveData>.selectable(
      searchHeader: searchHeader,
      gridChildAspectRatio: layout.imageArchive.aspectRatio,
      useHeading: false,
      appBar: ImageArchiveAppBar(
        searchHeader: searchHeader,
        breadcrumbRoot: context
                .read<SortableArchiveCubit<ImageArchiveData>>()
                .state
                .myPhotos
            ? ''
            : Lt.of(context).imageArchive,
      ),
      libraryItemGenerator: (imageArchive) =>
          ArchiveImage(sortable: imageArchive),
      selectedItemGenerator: (imageArchive) =>
          FullScreenArchiveImage(selected: imageArchive.data),
      emptyLibraryMessage: Lt.of(context).noImages,
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

class ImageArchiveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final SearchHeader searchHeader;
  final String breadcrumbRoot;

  const ImageArchiveAppBar({
    required this.searchHeader,
    this.breadcrumbRoot = '',
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.smallHeight);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final sortableState =
        context.watch<SortableArchiveCubit<ImageArchiveData>>().state;

    final title = translate.selectImage;
    if (searchHeader == SearchHeader.searchBar || sortableState.isSelected) {
      return AbiliaAppBar(
        iconData: sortableState.isSelected
            ? AbiliaIcons.pastPictureFromWindowsClipboard
            : AbiliaIcons.find,
        breadcrumbs: [sortableState.selected?.data.name ?? ''],
        title: sortableState.isSelected ? title : translate.searchImage,
      );
    }

    final breadcrumbs = [
      if (breadcrumbRoot.isNotEmpty) breadcrumbRoot,
      ...sortableState.breadCrumbPath(),
    ];

    if (searchHeader == SearchHeader.searchButton) {
      return AbiliaSearchAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        breadcrumbs: breadcrumbs,
        title: title,
        onImageSelected: (selectedImageData) =>
            Navigator.of(context).pop(selectedImageData),
      );
    }

    return AbiliaAppBar(
      iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
      breadcrumbs: breadcrumbs,
      title: title,
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;

  const ArchiveImage({
    required this.sortable,
    super.key,
  });

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
    super.key,
  });
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
