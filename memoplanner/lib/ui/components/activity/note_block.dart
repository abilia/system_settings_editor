import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class NoteBlock extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Text? textWidget;
  final ScrollController? scrollController;
  const NoteBlock({
    Key? key,
    this.text = '',
    this.textStyle,
    this.textWidget,
    this.scrollController,
  }) : super(key: key);

  @override
  State createState() => _NoteBlockState();
}

class _NoteBlockState extends State<NoteBlock> {
  late final ScrollController controller;
  late final TextStyle textStyle;

  @override
  void initState() {
    super.initState();
    controller = widget.scrollController ?? ScrollController();
    textStyle = widget.textStyle ?? bodyLarge;
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.textWidget;
    return Tts.data(
      data: text?.data ?? '',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return DefaultTextStyle(
            style: textStyle,
            child: ScrollArrows.vertical(
              controller: controller,
              child: SingleChildScrollView(
                padding: layout.note.notePadding,
                controller: controller,
                child: Stack(
                  children: [
                    Lines(
                      textRenderingSize: widget.text.calculateTextRenderSize(
                        constraints: constraints,
                        textStyle: textStyle,
                        padding: layout.note.notePadding,
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      ),
                    ),
                    if (text != null) text,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Lines extends StatelessWidget {
  final TextRenderingSize textRenderingSize;

  const Lines({
    required this.textRenderingSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final line = Padding(
      padding: EdgeInsets.only(
        top: textRenderingSize.textPainter.preferredLineHeight -
            layout.note.lineOffset,
        bottom: layout.note.lineOffset,
      ),
      child: const Divider(endIndent: 0),
    );

    return Column(
      children: List.generate(textRenderingSize.numberOfLines, (_) => line),
    );
  }
}
