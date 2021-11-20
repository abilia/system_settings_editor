import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/all.dart';

class ChecklistView extends StatefulWidget {
  final Checklist checklist;
  final DateTime? day;
  final Function(Question)? onTap;
  final EdgeInsetsGeometry padding;
  final bool preview;

  const ChecklistView(
    this.checklist, {
    this.day,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.preview = false,
    Key? key,
  }) : super(key: key);

  @override
  _ChecklistViewState createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  late final ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ArrowScrollable.verticalScrollArrows(
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        padding: widget.padding,
        itemCount: widget.checklist.questions.length,
        itemBuilder: (context, i) {
          final question = widget.checklist.questions[i];
          final day = widget.day;
          return QuestionView(
            question,
            inactive: widget.preview,
            signedOff:
                day != null && widget.checklist.isSignedOff(question, day),
            onTap: widget.onTap != null
                ? () => widget.onTap?.call(question)
                : null,
          );
        },
      ),
    );
  }
}

class QuestionView extends StatelessWidget {
  final Question question;
  final bool signedOff;
  final GestureTapCallback? onTap;
  final bool inactive;

  const QuestionView(
    this.question, {
    this.onTap,
    this.signedOff = false,
    this.inactive = false,
    Key? key,
  }) : super(key: key);

  static const duration = Duration(milliseconds: 200);
  static final padding = EdgeInsets.only(bottom: 6.0.s);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedTheme = theme.copyWith(
      textTheme: textTheme.copyWith(
        bodyText1: textTheme.bodyText1?.copyWith(
          color: AbiliaColors.white140,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    );

    return Tts.fromSemantics(
      SemanticsProperties(
        checked: question.checked,
        label: question.name,
      ),
      child: AnimatedTheme(
        data: signedOff ? selectedTheme : theme,
        duration: duration,
        child: Builder(
          builder: (context) => Padding(
            padding: padding,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: AnimatedContainer(
                  duration: duration,
                  decoration: signedOff
                      ? boxDecoration.copyWith(
                          border: Border.all(style: BorderStyle.none))
                      : boxDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textBaseline: TextBaseline.ideographic,
                    children: <Widget>[
                      if (question.hasImage)
                        InkWell(
                          borderRadius: borderRadius,
                          onTap: () => _showImage(
                            question.fileId,
                            question.image,
                            context,
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(6.0.s, 4.0.s, 0.0, 4.0.s),
                            child: AnimatedOpacity(
                              duration: duration,
                              opacity: signedOff ? 0.5 : 1.0,
                              child: FadeInCalendarImage(
                                key: TestKey.checklistQuestionImageKey,
                                imageFileId: question.fileId,
                                imageFilePath: question.image,
                                width: 40.s,
                                height: 40.s,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      if (question.hasTitle)
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(8.0.s, 10.0.s, 0.0, 10.0.s),
                            child: Text(
                              question.name,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(height: 1.0),
                            ),
                          ),
                        ),
                      IconTheme(
                        data: Theme.of(context)
                            .iconTheme
                            .copyWith(size: smallIconSize),
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(0.0, 12.0.s, 12.0.s, 12.0.s),
                          child: AnimatedCrossFade(
                            firstChild: Icon(
                              AbiliaIcons.checkboxSelected,
                              color: inactive
                                  ? AbiliaColors.green40
                                  : AbiliaColors.green,
                            ),
                            secondChild: Icon(
                              AbiliaIcons.checkboxUnselected,
                              color: inactive
                                  ? AbiliaColors.white140
                                  : AbiliaColors.black,
                            ),
                            crossFadeState: signedOff
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: duration,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImage(String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      useSafeArea: false,
      context: context,
      builder: (_) {
        return FullscreenImageDialog(
          fileId: fileId,
          filePath: filePath,
        );
      },
    );
  }
}
