import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageArchive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      builder: (context, archiveState) {
        final List<Sortable<ImageArchiveData>> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (currentFolderContent.isEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Tts(
                child: Text(
                  archiveState.currentFolderId == null
                      ? translate.noImages
                      : translate.emptyFolder,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
          );
        }
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent.map((sortable) {
            return sortable.isGroup
                ? LibraryFolder(
                    title: sortable.data.name,
                    fileId: sortable.data.fileId,
                    filePath: sortable.data.icon,
                    onTap: () {
                      BlocProvider.of<SortableArchiveBloc<ImageArchiveData>>(
                              context)
                          .add(FolderChanged(sortable.id));
                    },
                  )
                : ArchiveImage(imageArchiveData: sortable.data);
          }).toList(),
        );
      },
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final ImageArchiveData imageArchiveData;
  const ArchiveImage({Key key, @required this.imageArchiveData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0;
    final imageWidth = 84.0;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: imageArchiveData.name,
        image: imageArchiveData.fileId != null || imageArchiveData.file != null,
        button: true,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () async {
              final selectedImage = await showViewDialog<SelectedImage>(
                context: context,
                builder: (_) => ViewDialog(
                  leftPadding: 0.0,
                  rightPadding: 0.0,
                  verticalPadding: 0.0,
                  onOk: () => Navigator.of(context)
                      .maybePop(SelectedImage(id: imageId, path: iconPath)),
                  child: FullScreenImage(
                    backgroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: radius),
                    ),
                    fileId: imageId,
                    filePath: iconPath,
                  ),
                ),
              );
              if (selectedImage != null) {
                await Navigator.of(context)
                    .maybePop<SelectedImage>(selectedImage);
              }
            },
            borderRadius: borderRadius,
            child: Container(
              decoration: boxDecoration,
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (name != null)
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: abiliaTextTheme.caption,
                    ),
                  const SizedBox(height: 2),
                  FadeInAbiliaImage(
                    height: imageHeight,
                    width: imageWidth,
                    imageFileId: imageId,
                    imageFilePath: iconPath,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
