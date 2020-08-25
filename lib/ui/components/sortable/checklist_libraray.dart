import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ChecklistLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveBloc<ChecklistData>,
        SortableArchiveState<ChecklistData>>(
      builder: (context, archiveState) {
        final List<Sortable<ChecklistData>> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent
              .map(
                (sortable) => sortable.isGroup
                    ? ChecklistFolder(
                        sortable: sortable,
                        onTap: () {
                          BlocProvider.of<SortableArchiveBloc<ChecklistData>>(
                                  context)
                              .add(FolderChanged(sortable.id));
                        },
                      )
                    : LibraryChecklist(
                        checklist: sortable.data.checklist,
                      ),
              )
              .toList(),
        );
      },
    );
  }
}

class ChecklistFolder extends StatelessWidget {
  final GestureTapCallback onTap;
  final Sortable<ChecklistData> sortable;

  const ChecklistFolder({
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
              sortable.data.checklist.name,
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
                        imageFileId: sortable.data.checklist.fileId,
                        imageFilePath: sortable.data.checklist.icon,
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

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;
  const LibraryChecklist({Key key, @required this.checklist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.0;
    final imageWidth = 84.0;
    final imageId = checklist.fileId;
    final name = checklist.name;
    final iconPath = checklist.image;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(checklist),
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
                checklist.hasImage
                    ? FadeInAbiliaImage(
                        height: imageHeight,
                        width: imageWidth,
                        imageFileId: imageId,
                        imageFilePath: iconPath,
                      )
                    : Icon(
                        AbiliaIcons.check_button,
                        size: 84,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
