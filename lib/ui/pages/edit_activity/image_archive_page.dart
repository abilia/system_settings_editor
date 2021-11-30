import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  final VoidCallback? onCancel;
  final String initialFolder;
  final String? header;

  const ImageArchivePage(
      {Key? key, this.onCancel, this.initialFolder = '', this.header})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return LibraryPage<ImageArchiveData>(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: translate.selectPicture,
      ),
      initialFolder: initialFolder,
      rootHeading: header ?? translate.imageArchive,
      libraryItemGenerator: (imageArchive) =>
          ArchiveImage(sortable: imageArchive),
      libraryFolderGenerator: (imageArchive) => imageArchive.data.upload
          ? LibraryFolder(
              title: imageArchive.data.title(),
              color: AbiliaColors.blue,
              fileId: imageArchive.data.folderFileId(),
              filePath: imageArchive.data.folderFilePath(),
            )
          : LibraryFolder(
              title: imageArchive.data.title(),
              fileId: imageArchive.data.folderFileId(),
              filePath: imageArchive.data.folderFilePath(),
            ),
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
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;
  const ArchiveImage({Key? key, required this.sortable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0.s;
    final imageWidth = 84.0.s;
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
        padding: EdgeInsets.all(4.0.s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (name.isNotEmpty) ...[
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: abiliaTextTheme.caption,
              ),
              SizedBox(height: 2.s),
            ],
            FadeInAbiliaImage(
              height: imageHeight,
              width: imageWidth,
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
    Key? key,
    required this.selected,
  }) : super(key: key);
  final ImageArchiveData selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.s),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: FullScreenImage(
          backgroundDecoration: whiteNoBorderBoxDecoration,
          fileId: selected.fileId,
          filePath: selected.icon,
        ),
      ),
    );
  }
}
