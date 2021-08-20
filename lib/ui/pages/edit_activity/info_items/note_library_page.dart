import 'package:flutter/material.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class NoteLibraryPage extends StatelessWidget {
  const NoteLibraryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => LibraryPage<NoteData>(
        libraryItemGenerator: (note) => LibraryNote(content: note.data.text),
        selectedItemGenerator: (note) => FullScreenNote(noteData: note.data),
        emptyLibraryMessage: Translator.of(context).translate.noNotes,
        onOk: (selected) =>
            Navigator.of(context).pop<String>(selected.data.text),
      );
}

class LibraryNote extends StatelessWidget {
  final String content;
  const LibraryNote({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: content,
        button: true,
      ),
      child: Container(
        decoration: whiteBoxDecoration,
        padding: EdgeInsets.fromLTRB(4.s, 8.s, 4.s, 0),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Lines(
                lineHeight: content
                    .calulcateTextRenderSize(
                      constraints: constraints,
                      textStyle: Theme.of(context).textTheme.caption ?? caption,
                    )
                    .scaledLineHeight,
                numberOfLines: 6,
              ),
              Text(
                content,
                maxLines: 7,
                overflow: TextOverflow.fade,
                style: abiliaTextTheme.caption,
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
    Key? key,
    required this.noteData,
  }) : super(key: key);
  final NoteData noteData;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(12.s),
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
