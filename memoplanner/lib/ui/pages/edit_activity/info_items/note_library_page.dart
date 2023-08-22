import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class NoteLibraryPage extends StatelessWidget {
  const NoteLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocProvider<SortableArchiveCubit<NoteData>>(
        create: (_) => SortableArchiveCubit<NoteData>(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: LibraryPage<NoteData>.selectable(
          appBar: _NoteLibraryAppBar(),
          libraryItemGenerator: (note) => LibraryNote(content: note.data.text),
          selectedItemGenerator: (note) => FullScreenNote(noteData: note.data),
          emptyLibraryMessage: Lt.of(context).noNotes,
          onOk: (selected) => Navigator.of(context)
              .pop<InfoItem>(NoteInfoItem(selected.data.text)),
          useHeading: false,
        ),
      );
}

class LibraryNote extends StatelessWidget {
  final String content;
  const LibraryNote({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: content,
        button: true,
      ),
      child: Container(
        decoration: whiteBoxDecoration,
        padding: layout.libraryPage.notePadding,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Lines(
                textRenderingSize: content
                    .calculateTextRenderSize(
                      constraints: constraints,
                      textStyle:
                          Theme.of(context).textTheme.bodySmall ?? bodySmall,
                    )
                    .copyWith(numberOfLines: 5),
              ),
              Text(
                content,
                maxLines: 7,
                overflow: TextOverflow.fade,
                style: abiliaTextTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenNote extends StatelessWidget {
  const FullScreenNote({
    required this.noteData,
    Key? key,
  }) : super(key: key);
  final NoteData noteData;

  @override
  Widget build(BuildContext context) => Padding(
        padding: layout.templates.s1,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            decoration: whiteBoxDecoration,
            child: NoteBlock(
              text: noteData.text,
              textWidget: Text(noteData.text),
            ),
          ),
        ),
      );
}

class _NoteLibraryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final sortableState = context.watch<SortableArchiveCubit<NoteData>>().state;

    return AbiliaAppBar(
      iconData: AbiliaIcons.folder,
      title: Lt.of(context).fromTemplate,
      breadcrumbs: sortableState.selected != null
          ? [sortableState.selected!.data.name]
          : sortableState.breadCrumbPath(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.smallHeight);
}
