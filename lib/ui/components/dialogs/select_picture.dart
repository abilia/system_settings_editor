import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:uuid/uuid.dart';

class SelectPictureDialog extends StatefulWidget {
  final String previousImage;

  const SelectPictureDialog({Key key, this.previousImage}) : super(key: key);
  @override
  _SelectPictureDialogState createState() => _SelectPictureDialogState();
}

class _SelectPictureDialogState extends State<SelectPictureDialog> {
  bool imageArchiveView = false;
  final _picker = ImagePicker();
  SortableData selectedImageData;
  Function get onOk => selectedImageData != null
      ? () => Navigator.of(context).maybePop(SelectedImage(
            id: selectedImageData.fileId,
            path: selectedImageData.file,
          ))
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
      deleteButton: widget.previousImage != null || selectedImageData != null
          ? RemoveButton(
              key: TestKey.removePicture,
              onTap: () {
                Navigator.of(context).maybePop(SelectedImage(
                  id: '',
                  path: '',
                ));
              },
              icon: Icon(
                AbiliaIcons.delete_all_clear,
                color: AbiliaColors.white,
              ),
              text: translate.removePicture,
            )
          : null,
      heading: Text(translate.selectPicture, style: theme.textTheme.headline6),
      onOk: onOk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            key: TestKey.imageArchiveButton,
            leading: Icon(AbiliaIcons.folder),
            label: Text(
              translate.imageArchive,
              style: abiliaTheme.textTheme.bodyText1,
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
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async =>
                await _getExternalFile(source: ImageSource.gallery),
          ),
          SizedBox(height: 8.0),
          PickField(
            leading: Icon(AbiliaIcons.camera_photo),
            label: Text(
              translate.takeNewPhoto,
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async =>
                await _getExternalFile(source: ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Future _getExternalFile({ImageSource source}) async {
    final image = await _picker.getImage(source: source);
    if (image != null) {
      final id = Uuid().v4();
      final path = '${FileStorage.folder}/$id';
      await Navigator.of(context).maybePop(SelectedImage(
        id: id,
        path: path,
        newImage: File(image.path),
      ));
    }
  }

  Widget buildImageArchiveDialog() {
    return BlocBuilder<ImageArchiveBloc, ImageArchiveState>(
      builder: (innerContext, imageArchiveState) => ViewDialog(
        expanded: true,
        verticalPadding: 0.0,
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
        child: ImageArchive(),
      ),
    );
  }

  Text getImageArchiveHeading(ImageArchiveState state) {
    final folderName =
        state.allById[state.currentFolderId]?.sortableData?.name ??
            Translator.of(context).translate.imageArchive;
    return Text(folderName, style: abiliaTheme.textTheme.headline6);
  }
}

class SelectedImage extends Equatable {
  final String id;
  final String path;
  final File newImage;

  SelectedImage({
    @required this.id,
    @required this.path,
    this.newImage,
  });

  @override
  List<Object> get props => [id, path, newImage];
}
