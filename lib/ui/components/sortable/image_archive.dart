import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ImageArchive extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ImageArchive({
    Key key,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
      builder: (context, archiveState) {
        final Iterable<Sortable> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent.map((s) {
            return Column(
              children: <Widget>[
                s.isGroup
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Folder(
                          name: s.sortableData.name,
                          onTap: () {
                            BlocProvider.of<ImageArchiveBloc>(context)
                                .add(FolderChanged(s.id));
                          },
                        ),
                      )
                    : ArchiveImage(
                        name: s.sortableData.name,
                        imageId: s.sortableData.fileId,
                        iconPath: s.sortableData.icon,
                        onChanged: (val) {
                          BlocProvider.of<ImageArchiveBloc>(context)
                              .add(ArchiveImageSelected(val));
                          onChanged(val);
                        },
                      )
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class Folder extends StatelessWidget {
  final GestureTapCallback onTap;
  final String name;

  const Folder({
    Key key,
    @required this.onTap,
    @required this.name,
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
              name,
              style: abiliaTextTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              AbiliaIcons.folder,
              size: 86,
              color: AbiliaColors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class ArchiveImage extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String name;
  final String imageId;
  final String iconPath;
  const ArchiveImage({
    Key key,
    @required this.name,
    @required this.onChanged,
    @required this.imageId,
    @required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 86.0;
    final imageWidth = 84.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
          builder: (context, archiveState) {
        return ArchiveRadio(
          width: 110,
          heigth: 112,
          value: imageId,
          onChanged: onChanged,
          groupValue: archiveState.selectedImageId,
          child: Column(
            children: <Widget>[
              if (name != null)
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: abiliaTextTheme.caption,
                ),
              Container(
                height: imageHeight,
                width: imageWidth,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: AbiliaColors.white,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: FadeInCalendarImage(
                      imageFileId: imageId,
                      imageFilePath: iconPath,
                      width: imageWidth,
                      height: imageHeight,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

class ArchiveRadio<T> extends StatelessWidget {
  final Widget child;
  final double heigth, width;
  final T value, groupValue;
  final ValueChanged<T> onChanged;

  const ArchiveRadio({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.child,
    this.heigth,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      toggleableActiveColor: AbiliaColors.green,
    );
    return Theme(
      data: theme,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: borderRadius,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Ink(
                height: heigth,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AbiliaColors.transparantBlack[15],
                  ),
                  color: value == groupValue
                      ? AbiliaColors.white
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.fromLTRB(13, 2, 13, 4),
                child: child,
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio(
                      key: ObjectKey(key),
                      value: value,
                      groupValue: groupValue,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
