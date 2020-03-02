import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class SelectPictureDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.selectPicture, style: theme.textTheme.title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            leading: Icon(AbiliaIcons.folder),
            label: Text(
              translate.imageArchive,
              style: abiliaTheme.textTheme.body2,
            ),
            active: false,
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.my_photos),
            label: Text(
              translate.myPhotos,
              style: abiliaTheme.textTheme.body2,
            ),
            active: false,
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.camera_photo),
            label: Text(
              translate.takeNewPhoto,
              style: abiliaTheme.textTheme.body2,
            ),
            active: false,
          ),
        ],
      ),
    );
  }
}
