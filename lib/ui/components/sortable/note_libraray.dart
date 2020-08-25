import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class NoteLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableArchiveBloc<NoteData>,
        SortableArchiveState<NoteData>>(
      builder: (context, archiveState) {
        final List<Sortable<NoteData>> currentFolderContent =
            archiveState.allByFolder[archiveState.currentFolderId] ?? [];
        currentFolderContent.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: currentFolderContent
              .map((sortable) => sortable.isGroup
                  ? NoteFolder(
                      sortable: sortable,
                      onTap: () {
                        BlocProvider.of<SortableArchiveBloc<NoteData>>(context)
                            .add(FolderChanged(sortable.id));
                      },
                    )
                  : LibraryNote(content: sortable.data.text))
              .toList(),
        );
      },
    );
  }
}

class NoteFolder extends StatelessWidget {
  final GestureTapCallback onTap;
  final Sortable<NoteData> sortable;

  const NoteFolder({
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

class LibraryNote extends StatelessWidget {
  final String content;
  const LibraryNote({Key key, @required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 86.0;
    final imageWidth = 84.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).maybePop<String>(content);
          },
          borderRadius: borderRadius,
          child: Ink(
            width: imageWidth,
            height: imageHeight,
            decoration: whiteBoxDecoration,
            padding: const EdgeInsets.all(4.0),
            child: LayoutBuilder(builder: (context, constraints) {
              final textRenderSize = content.calulcateTextRenderSize(
                constraints: constraints,
                textStyle: abiliaTextTheme.caption,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              );
              return Stack(
                children: <Widget>[
                  Lines(
                    lineHeight: textRenderSize.scaledLineHeight,
                    numberOfLines: 6,
                  ),
                  Text(
                    content,
                    maxLines: 7,
                    overflow: TextOverflow.fade,
                    style: abiliaTextTheme.caption,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
