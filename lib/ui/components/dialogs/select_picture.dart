import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
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
  final _picker = ImagePicker();
  ImageArchiveData selectedImageData;
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
      return buildPictureSourceDialog();
    }
  }

  ViewDialog buildPictureSourceDialog() {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      deleteButton: widget.previousImage != null || selectedImageData != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: RemoveButton(
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
                  size: smallIconSize,
                ),
                text: translate.removePicture,
              ),
            )
          : null,
      heading: Text(translate.selectPicture, style: theme.textTheme.headline6),
      onOk: onOk,
      child: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, permission) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PickField(
                key: TestKey.imageArchiveButton,
                leading: const Icon(AbiliaIcons.folder),
                text: Text(
                  translate.imageArchive,
                  style: abiliaTheme.textTheme.bodyText1,
                ),
                onTap: () {
                  setState(() {
                    imageArchiveView = !imageArchiveView;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              PickField(
                key: TestKey.photosPickField,
                leading: const Icon(AbiliaIcons.my_photos),
                text: Text(
                  translate.myPhotos,
                  style: abiliaTheme.textTheme.bodyText1,
                ),
                onTap: permission.photosIsGrantedOrUndetermined
                    ? () async =>
                        await _getExternalFile(source: ImageSource.gallery)
                    : null,
              ),
              const SizedBox(height: 8.0),
              PickField(
                key: TestKey.cameraPickField,
                leading: const Icon(AbiliaIcons.camera_photo),
                text: Text(
                  translate.takeNewPhoto,
                  style: abiliaTheme.textTheme.bodyText1,
                ),
                onTap:
                    permission.status[Permission.camera].isGrantedOrUndetermined
                        ? () async =>
                            await _getExternalFile(source: ImageSource.camera)
                        : null,
              ),
            ],
          );
        },
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
    return BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
        SortableArchiveState<ImageArchiveData>>(
      builder: (innerContext, imageArchiveState) => ViewDialog(
        verticalPadding: 0.0,
        backButton: ActionButton(
          onPressed: () {
            if (imageArchiveState.currentFolderId == null) {
              setState(() => imageArchiveView = false);
            } else {
              BlocProvider.of<SortableArchiveBloc<ImageArchiveData>>(
                      innerContext)
                  .add(NavigateUp());
            }
          },
          themeData: darkButtonTheme,
          child: Icon(
            AbiliaIcons.navigation_previous,
            size: defaultIconSize,
          ),
        ),
        heading: getImageArchiveHeading(imageArchiveState),
        onOk: onOk,
        child: ImageArchive(),
      ),
    );
  }

  Text getImageArchiveHeading(SortableArchiveState state) {
    final folderName = state.allById[state.currentFolderId]?.data?.title() ??
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
