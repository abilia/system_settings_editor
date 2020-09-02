import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class EditNoteDialog extends StatefulWidget {
  final String text;
  static const padding = EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0);
  const EditNoteDialog({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  _EditNoteDialogState createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  TextEditingController _textEditingController;
  ScrollController _scrollController;

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
    return Theme(
      data: abiliaTheme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.zero,
          focusedBorder: transparentOutlineInputBorder,
          enabledBorder: transparentOutlineInputBorder,
        ),
      ),
      child: ViewDialog(
        leftPadding: 0.0,
        rightPadding: 0.0,
        verticalPadding: 0.0,
        backgroundColor: AbiliaColors.white,
        onOk: () => Navigator.of(context).maybePop(_textEditingController.text),
        deleteButton: AnimatedPositioned(
          duration: 200.milliseconds(),
          left: _textEditingController.text.isEmpty ? -100.0 : 12.0,
          child: RemoveButton(
            onTap: () => _textEditingController.text = '',
            icon: Icon(
              AbiliaIcons.delete,
              color: AbiliaColors.white,
              size: smallIconSize,
            ),
            text: Translator.of(context).translate.clear,
          ),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final textRenderSize =
              _textEditingController.text.calulcateTextRenderSize(
            constraints: constraints,
            textStyle: abiliaTextTheme.bodyText1,
            padding: EditNoteDialog.padding,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
          );
          return Stack(
            children: <Widget>[
              CupertinoScrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  padding: EditNoteDialog.padding,
                  child: Stack(
                    children: <Widget>[
                      Lines(
                        lineHeight: textRenderSize.scaledLineHeight,
                        numberOfLines: textRenderSize.numberOfLines,
                      ),
                      ConstrainedBox(
                        constraints: constraints.copyWith(
                            maxHeight: textRenderSize.scaledTextHeight),
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
              ),
              ArrowUp(controller: _scrollController),
              ArrowDown(controller: _scrollController),
            ],
          );
        }),
      ),
    );
  }
}