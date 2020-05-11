import 'package:flutter/material.dart';
import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class CheckListView extends StatefulWidget {
  final Checklist checklist;
  final DateTime day;

  const CheckListView(
    this.checklist, {
    @required this.day,
    Key key,
  }) : super(key: key);

  @override
  _CheckListViewState createState() => _CheckListViewState(ScrollController());
}

class _CheckListViewState extends State<CheckListView> {
  final ScrollController controller;

  _CheckListViewState(this.controller);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scrollbar(
          isAlwaysShown: true,
          controller: controller,
          child: ListView.builder(
            controller: controller,
            padding: Attachment.padding,
            itemCount: widget.checklist.questions.length,
            itemBuilder: (context, i) {
              final question = widget.checklist.questions[i];
              return QuestionView(
                question,
                signedOff: widget.checklist.isSignedOff(question, widget.day),
              );
            },
          ),
        ),
        ArrowUp(controller: controller),
        ArrowDown(controller: controller),
      ],
    );
  }
}

class QuestionView extends StatefulWidget {
  final Question question;
  final bool signedOff;

  const QuestionView(
    this.question, {
    this.signedOff = false,
    key,
  }) : super(key: key);

  @override
  _QuestionViewState createState() => _QuestionViewState(signedOff);
}

class _QuestionViewState extends State<QuestionView> {
  bool selected;
  _QuestionViewState(this.selected);
  static const duration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final body2 = textTheme.body2;
    final selectedTheme = theme.copyWith(
      textTheme: textTheme.copyWith(
        body2: body2.copyWith(
          color: AbiliaColors.white140,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    );

    return AnimatedTheme(
      data: selected ? selectedTheme : theme,
      duration: duration,
      child: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Material(
            color: AbiliaColors.white,
            borderRadius: borderRadius,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () => setState(() => selected = !selected),
              child: AnimatedContainer(
                duration: duration,
                decoration: selected
                    ? borderDecoration.copyWith(
                        border: Border.all(style: BorderStyle.none))
                    : borderDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textBaseline: TextBaseline.ideographic,
                  children: <Widget>[
                    if (widget.question.hasImage)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 4.0, 0.0, 4.0),
                        child: AnimatedOpacity(
                          duration: duration,
                          opacity: selected ? 0.5 : 1.0,
                          child: FadeInAbiliaImage(
                            imageFileId: widget.question.fileId,
                            imageFilePath: widget.question.image,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 10.0),
                      child: Text(
                        widget.question.name,
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 12.0, 12.0, 12.0),
                      child: AnimatedCrossFade(
                        firstChild: Icon(
                          AbiliaIcons.checkbox_selected,
                          color: AbiliaColors.green,
                        ),
                        secondChild: Icon(AbiliaIcons.checkbox_unselected),
                        crossFadeState: selected
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: duration,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
