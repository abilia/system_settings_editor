import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditQuestionPage extends StatelessWidget {
  final Question question;
  final File tempFile;

  const EditQuestionPage({
    this.question,
    this.tempFile,
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return EditImageAndName(
      maxLines: 8,
      minLines: 1,
      allowEmpty: false,
      imageAndName: question != null
          ? ImageAndName(
              question.name,
              SelectedImage.from(
                path: question.image,
                id: question.fileId,
                file: tempFile,
              ),
            )
          : null,
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phone_log,
        title: t.task,
        trailing: question != null
            ? Padding(
                padding: EdgeInsets.only(right: 12.0.s),
                child: RemoveButton(
                  onTap: () =>
                      Navigator.of(context).maybePop(ImageAndName.empty),
                  icon: Icon(
                    AbiliaIcons.delete_all_clear,
                    color: AbiliaColors.white,
                    size: 24.s,
                  ),
                  text: t.remove,
                ),
              )
            : null,
      ),
    );
  }
}
