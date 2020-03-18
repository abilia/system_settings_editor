import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class SelectPictureDialog extends StatefulWidget {
  final String previousImage;

  const SelectPictureDialog({Key key, this.previousImage}) : super(key: key);
  @override
  _SelectPictureDialogState createState() => _SelectPictureDialogState();
}

class _SelectPictureDialogState extends State<SelectPictureDialog> {
  bool imageArchiveView = false;
  String imageSelected;
  Function get onOk => imageSelected != null
      ? () => Navigator.of(context).maybePop(imageSelected)
      : null;

  @override
  Widget build(BuildContext context) {
    if (imageArchiveView) {
      return buildImageArchiveDialog(context);
    } else {
      return buildPictureSourceDialog(context);
    }
  }

  ViewDialog buildPictureSourceDialog(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      deleteButton: widget.previousImage != null || imageSelected != null
          ? RemoveButton(
              onTap: () {
                Navigator.of(context).maybePop('');
              },
              icon: Icon(
                AbiliaIcons.delete_all_clear,
                color: AbiliaColors.white,
              ),
              text: translate.removePicture,
            )
          : null,
      heading: Text(translate.selectPicture, style: theme.textTheme.title),
      onOk: onOk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            leading: Icon(AbiliaIcons.folder),
            label: Text(
              translate.imageArchive,
              style: abiliaTheme.textTheme.body2,
            ),
            onTap: () {
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
              var image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              print(image);
            },
          ),
        ],
      ),
    );
  }

  Widget buildImageArchiveDialog(BuildContext context) {
    return BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
      builder: (innerContext, imageArchiveState) => ViewDialog(
        expanded: true,
        backButton: ActionButton(
          onPressed: () {
            if (imageArchiveState.currentFolderId == null) {
              setState(() => imageArchiveView = false);
            } else {
              BlocProvider.of<ImageArchiveBloc>(innerContext).add(NavigateUp());
            }
          },
          themeData: darkButtonTheme,
          child: Icon(
            AbiliaIcons.navigation_previous,
            size: 32,
          ),
        ),
        heading: getImageArchiveHeading(imageArchiveState),
        onOk: onOk,
        child: ImageArchive(
          onChanged: (imageId) {
            setState(() => imageSelected = imageId);
          },
        ),
      ),
    );
  }

  Text getImageArchiveHeading(ImageArchiveState state) {
    final translate = Translator.of(context).translate;
    if (state.currentFolderId == null) {
      return Text(translate.imageArchive, style: abiliaTheme.textTheme.title);
    }
    final sortable = state.allById[state.currentFolderId];
    final sortableData = json.decode(sortable.data);
    final folderName = sortableData['name'];
    return Text(folderName, style: abiliaTheme.textTheme.title);
  }
}
