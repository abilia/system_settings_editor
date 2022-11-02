import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class EditNotePage extends StatefulWidget {
  final String text;
  static const padding = EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0);
  const EditNotePage({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _textEditingController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textEditingController = SpokenTextEditController.ifApplicable(
      context,
      text: widget.text,
    );
    _textEditingController.addListener(_textEditingListner);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_textEditingListner);

    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _textEditingListner() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = EdgeInsets.only(bottom: layout.navigationBar.height);
    final translate = Translator.of(context).translate;
    return Theme(
      data: abiliaTheme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.zero,
          focusedBorder: transparentOutlineInputBorder,
          enabledBorder: transparentOutlineInputBorder,
        ),
      ),
      child: Scaffold(
        backgroundColor: AbiliaColors.white,
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.edit,
          title: translate.enterText,
        ),
        bottomSheet: BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: _textEditingController.text.isNotEmpty
                ? () =>
                    Navigator.of(context).maybePop(_textEditingController.text)
                : null,
          ),
        ),
        body: Padding(
          padding: bottomPadding,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final textRenderSize =
                      _textEditingController.text.calculateTextRenderSize(
                    constraints: constraints,
                    textStyle:
                        Theme.of(context).textTheme.bodyText1 ?? bodyText1,
                    padding: EditNotePage.padding,
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  );
                  return ScrollArrows.vertical(
                    controller: _scrollController,
                    scrollbarAlwaysShown: true,
                    downCollapseMargin: layout.navigationBar.height,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EditNotePage.padding.add(bottomPadding),
                      child: Stack(
                        children: <Widget>[
                          Lines(textRenderingSize: textRenderSize),
                          ConstrainedBox(
                            constraints: constraints.copyWith(
                              maxHeight: textRenderSize.textPainter.height,
                            ),
                            child: TextField(
                              key: TestKey.input,
                              style: abiliaTextTheme.bodyText1,
                              controller: _textEditingController,
                              textCapitalization: TextCapitalization.sentences,
                              autofocus: true,
                              maxLines: null,
                              expands: true,
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: layout.fab.padding,
                child: TtsPlayButton(
                  controller: _textEditingController,
                  buttonStyle: actionButtonStyleNoneTransparantDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
