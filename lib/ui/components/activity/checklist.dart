import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/all.dart';

class CheckListView extends StatelessWidget {
  final Checklist checklist;
  final DateTime day;
  final Function(Question) onTap;
  final EdgeInsetsGeometry padding;
  final UnmodifiableMapView<int, File> tempImageFiles;
  final bool preview;

  CheckListView(
    this.checklist, {
    this.day,
    this.onTap,
    Key key,
    this.padding = EdgeInsets.zero,
    Map<int, File> tempImageFiles = const {},
    this.preview = false,
  })  : tempImageFiles = UnmodifiableMapView(tempImageFiles),
        super(key: key);

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CupertinoScrollbar(
          controller: controller,
          child: ListView.builder(
            controller: controller,
            padding: padding,
            itemCount: checklist.questions.length,
            itemBuilder: (context, i) {
              final question = checklist.questions[i];
              return QuestionView(
                question,
                inactive: preview,
                signedOff: day != null && checklist.isSignedOff(question, day),
                onTap: onTap != null && !preview ? () => onTap(question) : null,
                tempImageFile: tempImageFiles[question.id],
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

class QuestionView extends StatelessWidget {
  final Question question;
  final bool signedOff;
  final GestureTapCallback onTap;
  final File tempImageFile;
  final bool inactive;

  const QuestionView(
    this.question, {
    @required this.onTap,
    this.signedOff = false,
    key,
    this.tempImageFile,
    this.inactive = false,
  }) : super(key: key);

  static const duration = Duration(milliseconds: 400);
  static const padding = EdgeInsets.only(bottom: 4.0);

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
              color: Colors.transparent,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                const EdgeInsets.fromLTRB(6.0, 4.0, 0.0, 4.0),
                            child: AnimatedOpacity(
                              duration: duration,
                              opacity: signedOff ? 0.5 : 1.0,
                              child: FadeInCalendarImage(
                                key: TestKey.checklistQuestionImageKey,
                                imageFileId: question.fileId,
                                imageFilePath: question.image,
                                imageFile: tempImageFile,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      if (question.hasTitle)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 10.0),
                          child: Text(
                            question.name,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      Spacer(),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 12.0, 12.0, 12.0),
                        child: AnimatedCrossFade(
                          firstChild: Icon(
                            AbiliaIcons.checkbox_selected,
                            color: inactive
                                ? AbiliaColors.green40
                                : AbiliaColors.green,
                          ),
                          secondChild: Icon(
                            AbiliaIcons.checkbox_unselected,
                            color: inactive
                                ? AbiliaColors.white140
                                : AbiliaColors.black,
                          ),
                          crossFadeState: signedOff
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
      ),
    );
  }

  void _showImage(String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      context: context,
      builder: (_) {
        return FullScreenImage(
          fileId: fileId,
          filePath: filePath,
        );
      },
    );
  }
}
