import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ChecklistLibraryPage extends StatelessWidget {
  const ChecklistLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => LibraryPage<ChecklistData>.selectable(
        libraryItemGenerator: (checklist) =>
            LibraryChecklist(checklist: checklist.data.checklist),
        selectedItemGenerator: (checklist) =>
            FullScreenChecklist(checklist: checklist.data.checklist),
        emptyLibraryMessage: Translator.of(context).translate.noChecklists,
        onOk: (selected) =>
            Navigator.of(context).pop<Checklist>(selected.data.checklist),
      );
}

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;
  const LibraryChecklist({Key? key, required this.checklist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 84.s;
    final imageWidth = 84.s;
    final imageId = checklist.fileId;
    final name = checklist.name;
    final iconPath = checklist.image;
    return Tts.fromSemantics(
      SemanticsProperties(label: name),
      child: Container(
        decoration: boxDecoration,
        padding: EdgeInsets.all(4.s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (name.isNotEmpty)
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: abiliaTextTheme.caption,
              ),
            SizedBox(height: 2.s),
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
                  AbiliaIcons.checkButton,
                  size: 48.0.s,
                  color: AbiliaColors.white140,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenChecklist extends StatelessWidget {
  const FullScreenChecklist({
    Key? key,
    required this.checklist,
  }) : super(key: key);
  final Checklist checklist;

  @override
  Widget build(BuildContext context) => Container(
        margin:
            EdgeInsets.only(left: 12.s, top: 24.s, right: 16.s, bottom: 12.s),
        decoration: whiteBoxDecoration,
        child: ChecklistView(
          checklist,
          preview: true,
          padding: EdgeInsets.all(12.s),
        ),
      );
}
