import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditCategoryPage extends StatelessWidget {
  final String name, fileId, hintText;
  final File tempFile;

  const EditCategoryPage({
    this.name,
    @required this.hintText,
    this.fileId,
    this.tempFile,
    Key key,
  })  : assert(hintText != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return EditImageAndName(
      maxLines: 1,
      minLines: 1,
      allowEmpty: true,
      hintText: hintText,
      imageAndName: ImageAndName(
        name,
        SelectedImage.from(
          id: fileId,
          file: tempFile,
        ),
      ),
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phone_log,
        title: Translator.of(context).translate.editCategory,
      ),
    );
  }
}
