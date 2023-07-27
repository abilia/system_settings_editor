import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
    _textEditingController.addListener(_textEditingListener);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController
      ..removeListener(_textEditingListener)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _textEditingListener() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = EdgeInsets.only(bottom: layout.navigationBar.height);
    final translate = Lt.of(context);
    return WillPopScope(
      onWillPop: () async => await _saveNoteWarning(context),
      child: Theme(
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
                  ? () async =>
                      Navigator.of(context).pop(_textEditingController.text)
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
                          Theme.of(context).textTheme.bodyLarge ?? bodyLarge,
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
                                style: abiliaTextTheme.bodyLarge,
                                controller: _textEditingController,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                    transparent: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _saveNoteWarning(BuildContext context) async {
    final showSaveNoteDialog = _textEditingController.text != widget.text;
    if (showSaveNoteDialog) {
      await _showSaveNoteWarningDialog(context);
    }
    return false;
  }

  Future<void> _showSaveNoteWarningDialog(BuildContext context) async {
    final saveChanges = await showViewDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SaveNoteWarningDialog(),
      routeSettings: (DiscardWarningDialog).routeSetting(),
    );
    if (context.mounted && saveChanges != null) {
      if (saveChanges) {
        return Navigator.of(context).pop(_textEditingController.text);
      }
      Navigator.of(context).pop();
    }
  }
}
