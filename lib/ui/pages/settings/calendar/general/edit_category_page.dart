// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditCategoryPage extends StatelessWidget {
  final ImageAndName imageAndName;
  final String hintText;

  const EditCategoryPage({
    this.imageAndName,
    @required this.hintText,
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
      imageAndName: imageAndName,
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phone_log,
        title: Translator.of(context).translate.editCategory,
      ),
    );
  }
}
