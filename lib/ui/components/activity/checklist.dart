import 'package:flutter/material.dart';
import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class CheckListView extends StatefulWidget {
  final Checklist checklist;

  const CheckListView(this.checklist, {Key key}) : super(key: key);

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
            itemBuilder: (context, i) =>
                QuestionView(widget.checklist.questions[i]),
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

  const QuestionView(this.question, {Key key}) : super(key: key);

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  bool selected = false;
  static const duration = Duration(milliseconds: 400);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedTheme = theme.copyWith(
      textTheme: textTheme.copyWith(
        bodyText1: textTheme.bodyText1.copyWith(
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
                        style: Theme.of(context).textTheme.bodyText1,
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
