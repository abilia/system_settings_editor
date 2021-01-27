import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageArchivePage extends StatelessWidget {
  const ImageArchivePage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return LibraryPage<ImageArchiveData>(
      appBar: NewAbiliaAppBar(
        iconData: AbiliaIcons.past_picture_from_windows_clipboard,
        title: translate.selectPicture,
      ),
      libraryItemGenerator: (Sortable<ImageArchiveData> imageArchive) =>
          ArchiveImage(sortable: imageArchive),
      selectedItemGenerator: (Sortable<ImageArchiveData> imageArchive) =>
          FullScreenArchiveImage(
        selected: imageArchive.data,
      ),
      emptyLibraryMessage: translate.noImages,
      onCancel: () => Navigator.of(context)..maybePop()..maybePop(),
      onOk: (selected) => Navigator.of(context).pop<SelectedImage>(
        SelectedImage(
          id: selected?.data?.fileId,
          path: selected?.data?.file,
        ),
      ),
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;
  const ArchiveImage({Key key, @required this.sortable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0;
    final imageWidth = 84.0;
    final imageArchiveData = sortable.data;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: imageArchiveData.name,
        image: imageArchiveData.fileId != null || imageArchiveData.file != null,
        button: true,
      ),
      child: Container(
        decoration: boxDecoration,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (name != null) ...[
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: abiliaTextTheme.caption,
              ),
              const SizedBox(height: 2),
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
    Key key,
    @required this.selected,
  }) : super(key: key);
  final ImageArchiveData selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
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
