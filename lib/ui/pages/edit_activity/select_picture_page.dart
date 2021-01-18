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

final _log = Logger((SelectPicturePage).toString());

class SelectPicturePage extends StatefulWidget {
  final String previousImage;

  const SelectPicturePage({Key key, this.previousImage}) : super(key: key);
  @override
  _SelectPicturePageState createState() => _SelectPicturePageState();
}

class _SelectPicturePageState extends State<SelectPicturePage> {
  ImageArchiveData selectedImageData;
  Function get onOk => selectedImageData != null
      ? () => Navigator.of(context).maybePop(SelectedImage(
            id: selectedImageData.fileId,
            path: selectedImageData.file,
          ))
      : null;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      deleteButton: widget.previousImage != null || selectedImageData != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: RemoveButton(
                key: TestKey.removePicture,
                onTap: () {
                  Navigator.of(context).maybePop(
                    SelectedImage(
                      id: '',
                      path: '',
                    ),
                  );
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
            text: Text(translate.imageArchive),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
                      create: (_) => SortableArchiveBloc<ImageArchiveData>(
                        sortableBloc: BlocProvider.of<SortableBloc>(context),
                      ),
                      child: ImageArchivePage(),
                    ),
                  ),
                ),
              );
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
                text: Text(text),
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
