import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:sortables/bloc/all.dart';

class ChecklistLibraryPage extends StatelessWidget {
  const ChecklistLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocProvider<SortableArchiveCubit<ChecklistData>>(
        create: (_) => SortableArchiveCubit<ChecklistData>(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: LibraryPage<ChecklistData>.selectable(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.documents,
            title: Translator.of(context).translate.selectFromLibrary,
          ),
          libraryItemGenerator: (checklist) =>
              LibraryChecklist(checklist: checklist.data.checklist),
          selectedItemGenerator: (checklist) =>
              FullScreenChecklist(checklist: checklist.data.checklist),
          emptyLibraryMessage: Translator.of(context).translate.noChecklists,
          onOk: (selected) =>
              Navigator.of(context).pop<Checklist>(selected.data.checklist),
        ),
      );
}

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;
  const LibraryChecklist({
    required this.checklist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = layout.libraryPage.imageHeight;
    final imageWidth = layout.libraryPage.imageWidth;
    final imageId = checklist.fileId;
    final name = checklist.name;
    final iconPath = checklist.image;
    return Tts.fromSemantics(
      SemanticsProperties(label: name),
      child: Container(
        decoration: boxDecoration,
        padding: layout.templates.s3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (name.isNotEmpty)
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: abiliaTextTheme.bodySmall,
              ),
            SizedBox(height: layout.libraryPage.textImageDistance),
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
                  size: layout.icon.large,
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
    required this.checklist,
    Key? key,
  }) : super(key: key);
  final Checklist checklist;

  @override
  Widget build(BuildContext context) => Container(
        margin: layout.templates.m3,
        decoration: whiteBoxDecoration,
        child: ChecklistView(checklist, padding: layout.templates.s1),
      );
}
