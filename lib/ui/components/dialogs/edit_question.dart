import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class QuestionResult {
  final File newImage;
  final Question question;
  const QuestionResult(this.question, this.newImage);
  static QuestionResult get empty => const QuestionResult(null, null);
  bool get isNotEmpty => question != null;
  bool get hasNewImage => newImage != null;
}

class EditQuestionDialog extends StatefulWidget {
  final Question question;

  const EditQuestionDialog({this.question, Key key}) : super(key: key);

  @override
  _EditQuestionDialogState createState() => question == null
      ? _EditQuestionDialogState()
      : _EditQuestionDialogState(question);
}

class _EditQuestionDialogState extends State<EditQuestionDialog> {
  _EditQuestionDialogState([this.question = const Question(id: 0, name: '')]);
  Question question;
  bool get canSave => question.hasImage || question.hasTitle;
  File newImage;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.task, style: theme.textTheme.headline6),
      onOk: canSave
          ? () =>
              Navigator.of(context).maybePop(QuestionResult(question, newImage))
          : null,
      deleteButton: widget.question != null
          ? RemoveButton(
              onTap: () => Navigator.of(context).maybePop(QuestionResult.empty),
              icon: Icon(
                AbiliaIcons.delete_all_clear,
                color: AbiliaColors.white,
              ),
              text: translate.remove,
            )
          : null,
      child: Column(
        children: <Widget>[
          NameAndPictureWidget(
            imageFileId: question.fileId,
            imageFilePath: question.image,
            newImage: newImage,
            text: question.name,
            onTextEdit: (text) =>
                setState(() => question = question.copyWith(name: text)),
            onImageSelected: (selectedImage) => setState(() {
              newImage = selectedImage.newImage;
              question = question.copyWith(
                  fileId: selectedImage.id, image: selectedImage.path);
            }),
          ),
        ],
      ),
    );
  }
}
