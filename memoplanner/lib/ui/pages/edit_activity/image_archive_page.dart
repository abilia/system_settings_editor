import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  final VoidCallback? onCancel;
  final String initialFolder;
  final String? header;
  final bool showSearch;
  final bool myPhotos;

  const ImageArchivePage({
    Key? key,
    this.onCancel,
    this.initialFolder = '',
    this.header,
    this.showSearch = false,
    this.myPhotos = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
      create: (_) => SortableArchiveCubit<ImageArchiveData>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
        initialFolderId: initialFolder,
        myPhotos: myPhotos,
      ),
      child: Builder(
        builder: (context) {
          return LibraryPage<ImageArchiveData>.selectable(
            appBar: AbiliaAppBar(
              iconData: showSearch
                  ? AbiliaIcons.find
                  : AbiliaIcons.pastPictureFromWindowsClipboard,
              title: showSearch ? translate.searchImage : translate.selectImage,
            ),
            showSearch: showSearch,
            gridChildAspectRatio: layout.imageArchive.aspectRatio,
            rootHeading: header ?? translate.imageArchive,
            libraryItemGenerator: (imageArchive) =>
                ArchiveImage(sortable: imageArchive),
            selectedItemGenerator: (imageArchive) =>
                FullScreenArchiveImage(selected: imageArchive.data),
            emptyLibraryMessage: translate.noImages,
            onCancel: onCancel,
            onOk: (selected) {
              Navigator.of(context).pop<SelectedImageData>(
                SelectedImageData(
                  selectedImage: AbiliaFile.from(
                    id: selected.data.fileId,
                    path: selected.data.file,
                  ),
                  fromSearch: showSearch,
                ),
              );
            },
          );
        },
      ),
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
    return Tts.fromSemantics(
      SemanticsProperties(
        label: imageArchiveData.name,
        image: imageArchiveData.fileId.isNotEmpty ||
            imageArchiveData.file.isNotEmpty,
        button: true,
      ),
      child: Container(
        decoration: boxDecoration,
        padding: EdgeInsets.all(layout.imageArchive.imagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (name.isNotEmpty) ...[
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: abiliaTextTheme.bodySmall,
              ),
              SizedBox(height: layout.imageArchive.imageNameBottomPadding),
            ],
            Flexible(
              child: FadeInAbiliaImage(
                height: layout.imageArchive.imageHeight,
                width: layout.imageArchive.imageWidth,
                imageFileId: imageId,
                imageFilePath: iconPath,
              ),
            ),
          ],
        ),
      ),
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
