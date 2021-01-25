import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';

final _log = Logger((SelectPicturePage).toString());

class SelectPicturePage extends StatelessWidget {
  final SelectedImage selectedImage;

  const SelectPicturePage({
    Key key,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        iconData: AbiliaIcons.past_picture_from_windows_clipboard,
        title: translate.selectPicture,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (selectedImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Separated(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, top: 24.0, bottom: 18.0),
                  child: Column(
                    children: [
                      SelectedImageWidget(selectedImage: selectedImage),
                      const SizedBox(height: 10.0),
                      RemoveButton(
                        key: TestKey.removePicture,
                        onTap: () {
                          Navigator.of(context).maybePop(
                            SelectedImage.none(),
                          );
                        },
                        icon: Icon(
                          AbiliaIcons.delete_all_clear,
                          color: AbiliaColors.white,
                          size: smallIconSize,
                        ),
                        text: translate.removePicture,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0.0),
            child: Column(
              children: [
                PickField(
                  key: TestKey.imageArchiveButton,
                  leading: const Icon(AbiliaIcons.folder),
                  text: Text(translate.imageArchive),
                  onTap: () async {
                    final selectedImage =
                        await Navigator.of(context).push<SelectedImage>(
                      MaterialPageRoute(
                        builder: (_) => CopiedAuthProviders(
                          blocContext: context,
                          child: BlocProvider<
                              SortableArchiveBloc<ImageArchiveData>>(
                            create: (_) =>
                                SortableArchiveBloc<ImageArchiveData>(
                              sortableBloc:
                                  BlocProvider.of<SortableBloc>(context),
                            ),
                            child: const ImageArchivePage(),
                          ),
                        ),
                      ),
                    );
                    if (selectedImage != null) {
                      await Navigator.of(context).maybePop(selectedImage);
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                ImageSourceWidget(
                  text: translate.myPhotos,
                  imageSource: ImageSource.gallery,
                  permission: Platform.isAndroid
                      ? Permission.storage
                      : Permission.photos,
                ),
                const SizedBox(height: 8.0),
                ImageSourceWidget(
                  text: translate.takeNewPhoto,
                  imageSource: ImageSource.camera,
                  permission: Permission.camera,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: GreyButton(
          icon: AbiliaIcons.close_program,
          text: translate.cancel,
          onPressed: Navigator.of(context).pop,
        ),
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
            file: File(image.path),
          ),
        );
      }
    } on PlatformException catch (e) {
      _log.warning(e);
    }
  }
}