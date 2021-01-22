import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class EditNotePage extends StatefulWidget {
  final String text;
  static const padding = EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0);
  const EditNotePage({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  TextEditingController _textEditingController;
  ScrollController _scrollController;
  static const _bottomBottomNavigationHeight = 84.0;
  static const _bottomPadding =
      EdgeInsets.only(bottom: _bottomBottomNavigationHeight);

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
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
        appBar: NewAbiliaAppBar(
          iconData: AbiliaIcons.edit,
          title: translate.enterText,
        ),
        bottomSheet: BottomNavigation(
          backNavigationWidget: GreyButton(
            icon: AbiliaIcons.close_program,
            text: translate.cancel,
            onPressed: Navigator.of(context).maybePop,
          ),
          forwardNavigationWidget: GreenButton(
            key: TestKey.okDialog,
            icon: AbiliaIcons.ok,
            text: translate.ok,
            onPressed: _textEditingController.text.isNotEmpty
                ? () =>
                    Navigator.of(context).maybePop(_textEditingController.text)
                : null,
          ),
        ),
        body: Padding(
          padding: _bottomPadding,
          child: LayoutBuilder(builder: (context, constraints) {
            final textRenderSize =
                _textEditingController.text.calulcateTextRenderSize(
              constraints: constraints,
              textStyle: abiliaTextTheme.bodyText1,
              padding: EditNotePage.padding,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
            );
            return VerticalScrollArrows(
              controller: _scrollController,
              scrollbarAlwaysShown: true,
              downCollapseMargin: _bottomBottomNavigationHeight,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EditNotePage.padding.add(_bottomPadding),
                child: Stack(
                  children: <Widget>[
                    Lines(
                      lineHeight: textRenderSize.scaledLineHeight,
                      numberOfLines: textRenderSize.numberOfLines,
                    ),
                    ConstrainedBox(
                      constraints: constraints.copyWith(
                        maxHeight: textRenderSize.scaledTextHeight,
                      ),
                      child: TextField(
                        key: TestKey.input,
                        style: abiliaTextTheme.bodyText1,
                        controller: _textEditingController,
                        autofocus: true,
                        maxLines: null,
                        expands: true,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
