import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

final _log = Logger((SelectPictureDialog).toString());

class SelectPictureDialog extends StatefulWidget {
  final String previousImage;

  const SelectPictureDialog({Key key, this.previousImage}) : super(key: key);
  @override
  _SelectPictureDialogState createState() => _SelectPictureDialogState();
}

class _SelectPictureDialogState extends State<SelectPictureDialog> {
  bool imageArchiveView = false;
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
      child: Column(
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
          ImageSourceWidget(
            text: translate.myPhotos,
            imageSource: ImageSource.gallery,
            permission:
                Platform.isAndroid ? Permission.storage : Permission.photos,
          ),
          const SizedBox(height: 8.0),
          ImageSourceWidget(
            text: translate.takeNewPhoto,
            imageSource: ImageSource.camera,
            permission: Permission.camera,
          ),
        ],
      ),
    );
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

class ImageSourceWidget extends StatelessWidget {
  ImageSourceWidget({
    Key key,
    @required this.imageSource,
    @required this.permission,
    @required this.text,
  }) : super(key: key);

  final ImageSource imageSource;
  final Permission permission;
  final String text;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) {
        return Row(
          children: [
            Expanded(
              child: PickField(
                key: ObjectKey(imageSource),
                leading: permission.icon,
                text: Text(
                  text,
                  style: abiliaTheme.textTheme.bodyText1,
                ),
                onTap: permissionState.status[permission].isPermanentlyDenied
                    ? null
                    : () async => await _getExternalFile(context),
              ),
            ),
            if (permissionState.status[permission].isPermanentlyDenied)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InfoButton(
                  key: Key('$imageSource$permission'),
                  onTap: () => showViewDialog(
                    context: context,
                    builder: (context) =>
                        PermissionInfoDialog(permission: permission),
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  Future _getExternalFile(BuildContext context) async {
    try {
      final image = await _picker.getImage(source: imageSource);
      if (image != null) {
        final id = Uuid().v4();
        final path = '${FileStorage.folder}/$id';
        await Navigator.of(context).maybePop(
          SelectedImage(
            id: id,
            path: path,
            newImage: File(image.path),
          ),
        );
      }
    } on PlatformException catch (e) {
      _log.warning(e);
    }
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
