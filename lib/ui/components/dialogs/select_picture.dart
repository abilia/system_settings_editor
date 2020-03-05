import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/sortable/image_archive.dart';
import 'package:seagull/ui/theme.dart';

class SelectPictureDialog extends StatefulWidget {
  final BuildContext outerContext;
  final ValueChanged<String> onChanged;

  const SelectPictureDialog({
    Key key,
    @required this.outerContext,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _SelectPictureDialogState createState() => _SelectPictureDialogState();
}

class _SelectPictureDialogState extends State<SelectPictureDialog> {
  bool imageArchiveView = false;
  String imageSelected;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      fullScreen: imageArchiveView,
      heading: Text(translate.selectPicture, style: theme.textTheme.title),
      onOk: imageSelected != null
          ? () {
              widget.onChanged(imageSelected);
            }
          : null,
      child: imageArchiveView
          ? ImageArchive(
              outerContext: widget.outerContext,
              onChanged: (imageId) {
                setState(() {
                  imageSelected = imageId;
                });
              },
            )
          : buildSelectPictureSource(translate),
    );
  }

  Column buildSelectPictureSource(Translated translate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PickField(
          leading: Icon(AbiliaIcons.folder),
          label: Text(
            translate.imageArchive,
            style: abiliaTheme.textTheme.body2,
          ),
          onTap: () async {
            setState(() {
              imageArchiveView = !imageArchiveView;
            });
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
            var image = await ImagePicker.pickImage(source: ImageSource.camera);
            print(image);
          },
        ),
      ],
    );
  }
}
