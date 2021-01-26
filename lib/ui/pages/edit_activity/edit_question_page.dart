import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class QuestionResult {
  final File newImage;
  final Question question;
  const QuestionResult(this.question, this.newImage);
  static QuestionResult get empty => const QuestionResult(null, null);
  bool get isNotEmpty => question != null;
  bool get hasNewImage => newImage != null;
}

class EditQuestionPage extends StatefulWidget {
  final Question question;

  const EditQuestionPage({this.question, Key key}) : super(key: key);

  @override
  _EditQuestionPageState createState() => question == null
      ? _EditQuestionPageState()
      : _EditQuestionPageState(question);
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  _EditQuestionPageState([this.question = const Question(id: 0, name: '')]);
  Question question;
  bool get canSave => question.hasImage || question.hasTitle;
  File newImage;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final heading = translate.name;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        iconData: AbiliaIcons.phone_log,
        title: translate.task,
        trailing: widget.question != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: RemoveButton(
                  onTap: () =>
                      Navigator.of(context).maybePop(QuestionResult.empty),
                  icon: Icon(
                    AbiliaIcons.delete_all_clear,
                    color: AbiliaColors.white,
                    size: 24,
                  ),
                  text: translate.remove,
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectPictureWidget(
                  selectedImage: SelectedImage(
                    id: question.fileId,
                    path: question.image,
                    file: newImage,
                  ),
                  onImageSelected: (selectedImage) => setState(
                    () {
                      newImage = selectedImage.file;
                      question = question.copyWith(
                          fileId: selectedImage.id, image: selectedImage.path);
                    },
                  ),
                  errorState: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tts.fromSemantics(
                    SemanticsProperties(label: heading),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SubHeading(heading),
                        TextField(
                          textCapitalization: TextCapitalization.sentences,
                          style: Theme.of(context).textTheme.bodyText1,
                          autofocus: true,
                          onEditingComplete: Navigator.of(context).maybePop,
                          onChanged: (text) => setState(
                              () => question = question.copyWith(name: text)),
                          maxLines: 12,
                          minLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: GreenButton(
          icon: AbiliaIcons.ok,
          text: translate.ok,
          onPressed: canSave
              ? () => Navigator.of(context)
                  .maybePop(QuestionResult(question, newImage))
              : null,
        ),
      ),
    );
  }
}
