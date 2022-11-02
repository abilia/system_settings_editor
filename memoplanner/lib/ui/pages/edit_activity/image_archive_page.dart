import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class ImageArchivePage extends StatelessWidget {
  final VoidCallback? onCancel;
  final String initialFolder;
  final String? header;

  const ImageArchivePage({
    Key? key,
    this.onCancel,
    this.initialFolder = '',
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
      create: (_) => SortableArchiveCubit<ImageArchiveData>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
        initialFolderId: initialFolder,
        visibilityFilter: (imageArchive) => !imageArchive.data.myPhotos,
      ),
      child: LibraryPage<ImageArchiveData>.selectable(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
          title: translate.selectImage,
        ),
        gridChildAspectRatio: layout.imageArchive.aspectRatio,
        rootHeading: header ?? translate.imageArchive,
        libraryItemGenerator: (imageArchive) =>
            ArchiveImage(sortable: imageArchive),
        selectedItemGenerator: (imageArchive) =>
            FullScreenArchiveImage(selected: imageArchive.data),
        emptyLibraryMessage: translate.noImages,
        onCancel: onCancel,
        onOk: (selected) => Navigator.of(context).pop<AbiliaFile>(
          AbiliaFile.from(
            id: selected.data.fileId,
            path: selected.data.file,
          ),
        ),
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
                style: abiliaTextTheme.caption,
              ),
              SizedBox(height: layout.imageArchive.imageNameBottomPadding),
            ],
            FadeInAbiliaImage(
              height: layout.imageArchive.imageHeight,
              width: layout.imageArchive.imageWidth,
              imageFileId: imageId,
              imageFilePath: iconPath,
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
