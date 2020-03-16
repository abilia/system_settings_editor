import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/user_file/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:uuid/uuid.dart';

class SelectPictureDialog extends StatefulWidget {
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
      return buildImageArchiveDialog();
    } else {
      return buildPictureSourceDialog(context);
    }
  }

  ViewDialog buildPictureSourceDialog(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.selectPicture, style: theme.textTheme.title),
      onOk: onOk,
      child: Builder(
        builder: (BuildContext innerContext) => Column(
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
                var image = await ImagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                final id = Uuid().v4();
                BlocProvider.of<UserFileBloc>(innerContext)
                    .add(FileAdded(id, image));
                setState(() => imageSelected = id);
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
                final image = await ImagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                final id = Uuid().v4();
                BlocProvider.of<UserFileBloc>(innerContext)
                    .add(FileAdded(id, image));
                setState(() => imageSelected = id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageArchiveDialog() {
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
