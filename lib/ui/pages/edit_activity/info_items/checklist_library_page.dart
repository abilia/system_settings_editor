import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ChecklistLibraryPage extends StatelessWidget {
  const ChecklistLibraryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => LibraryPage<ChecklistData>(
        libraryItemGenerator: (checklist) =>
            LibraryChecklist(checklist: checklist.data.checklist),
        selectedItemGenerator: (checklist) =>
            FullScreenCheckList(checklist: checklist.data.checklist),
        emptyLibraryMessage: Translator.of(context).translate.noChecklists,
        onOk: (selected) =>
            Navigator.of(context).pop<Checklist>(selected.data.checklist),
      );
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
    return Tts.fromSemantics(
      SemanticsProperties(label: name),
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
            if (checklist.hasImage)
              FadeInAbiliaImage(
                height: imageHeight,
                width: imageWidth,
                imageFileId: imageId,
                imageFilePath: iconPath,
              )
            else
              SizedBox(
                height: imageHeight,
                child: Icon(
                  AbiliaIcons.check_button,
                  size: 48.0,
                  color: AbiliaColors.white140,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenCheckList extends StatelessWidget {
  const FullScreenCheckList({
    Key key,
    @required this.checklist,
  }) : super(key: key);
  final Checklist checklist;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(
            left: 12.0, top: 24.0, right: 16.0, bottom: 12.0),
        decoration: whiteBoxDecoration,
        child: CheckListView(
          checklist,
          preview: true,
          padding: const EdgeInsets.all(12.0),
        ),
      );
}
