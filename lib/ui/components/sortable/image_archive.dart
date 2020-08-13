import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ImageArchive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
      builder: (context, archiveState) {
        final List<Sortable> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent.map((sortable) {
            return sortable.isGroup
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Folder(
                      sortable: sortable,
                      onTap: () {
                        BlocProvider.of<ImageArchiveBloc>(context)
                            .add(FolderChanged(sortable.id));
                      },
                    ),
                  )
                : ArchiveImage(imageArchiveData: sortable.data);
          }).toList(),
        );
      },
    );
  }
}

class Folder extends StatelessWidget {
  final GestureTapCallback onTap;
  final Sortable<ImageArchiveData> sortable;

  const Folder({
    Key key,
    @required this.onTap,
    @required this.sortable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Text(
              sortable.data.name,
              style: abiliaTextTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
            Stack(
              children: [
                Icon(
                  AbiliaIcons.folder,
                  size: 86,
                  color: AbiliaColors.orange,
                ),
                Positioned(
                  bottom: 16,
                  left: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 42 / 66,
                      child: FadeInAbiliaImage(
                        imageFileId: sortable.data.fileId,
                        imageFilePath: sortable.data.icon,
                        width: 66,
                        height: 66,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
          builder: (context, archiveState) {
        final imageId = imageArchiveData.fileId;
        final name = imageArchiveData.name;
        final iconPath = imageArchiveData.file;
        return Material(
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
        );
      }),
    );
  }
}
