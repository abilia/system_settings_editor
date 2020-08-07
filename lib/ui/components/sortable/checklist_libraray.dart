import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ChecklistLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortableBloc, SortableState>(
      builder: (context, state) {
        final sortableChecklist = state is SortablesLoaded
            ? state.sortables.whereType<Sortable<ChecklistData>>().toList()
            : <Sortable<ChecklistData>>[];
        sortableChecklist.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: ViewDialog.verticalPadding),
          crossAxisCount: 3,
          childAspectRatio: 0.96,
          children: sortableChecklist
              .map(
                (sortable) => LibraryChecklist(
                  checklist: sortable.data.checklist,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;
  const LibraryChecklist({Key key, @required this.checklist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 86.0;
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
    );
  }
}
