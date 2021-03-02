import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/all.dart';

class ChecklistView extends StatelessWidget {
  final Checklist checklist;
  final DateTime day;
  final Function(Question) onTap;
  final EdgeInsetsGeometry padding;
  final UnmodifiableMapView<int, File> tempImageFiles;
  final bool preview;

  ChecklistView(
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
    return VerticalScrollArrows(
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
            onTap: onTap != null ? () => onTap(question) : null,
            tempImageFile: tempImageFiles[question.id],
          );
        },
      ),
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
  static final padding = EdgeInsets.only(bottom: 6.0.s);

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
                                imageFile: tempImageFile,
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
                                  .copyWith(height: 1.0),
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
