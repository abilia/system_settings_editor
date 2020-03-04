import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/dialogs/image_archive_dialog.dart';
import 'package:seagull/ui/theme.dart';

class SelectPictureDialog extends StatelessWidget {
  final BuildContext outerContext;

  const SelectPictureDialog({Key key, this.outerContext}) : super(key: key);

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
            onTap: () async {
              await Navigator.of(context).maybePop();
              await showDialog(
                context: context,
                builder: (innerContext) => ImageArchiveDialog(
                  outerContext: outerContext,
                ),
              );
            },
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.my_photos),
            label: Text(
              translate.myPhotos,
              style: abiliaTheme.textTheme.body2,
            ),
            onTap: () async {
              var image =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              print(image);
            },
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.camera_photo),
            label: Text(
              translate.takeNewPhoto,
              style: abiliaTheme.textTheme.body2,
            ),
            onTap: () async {
              var image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              print(image);
            },
          ),
        ],
      ),
    );
  }
}
