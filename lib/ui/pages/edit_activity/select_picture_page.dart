import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

final _log = Logger((SelectPicturePage).toString());

class SelectPicturePage extends StatelessWidget {
  final AbiliaFile selectedImage;

  SelectPicturePage({Key? key, required this.selectedImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.past_picture_from_windows_clipboard,
        title: translate.selectPicture,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (selectedImage.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 12.0.s),
              child: Separated(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 12.0.s, top: 24.0.s, bottom: 18.0.s),
                  child: Column(
                    children: [
                      SelectedImageWidget(selectedImage: selectedImage),
                      SizedBox(height: 10.0.s),
                      RemoveButton(
                        key: TestKey.removePicture,
                        onTap: () {
                          Navigator.of(context).maybePop(AbiliaFile.empty);
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
            padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
            child:
                SelectPictureMainContent(imageCallback: (selectedImage) async {
              await Navigator.of(context).maybePop(selectedImage);
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }
}

class SelectPictureMainContent extends StatelessWidget {
  final ValueChanged<AbiliaFile> imageCallback;

  const SelectPictureMainContent({Key? key, required this.imageCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            PickField(
              key: TestKey.imageArchiveButton,
              leading: const Icon(AbiliaIcons.folder),
              text: Text(translate.imageArchive),
              onTap: () async {
                final selectedImage =
                    await Navigator.of(context).push<AbiliaFile>(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: const ImageArchivePage(),
                    ),
                  ),
                );
                if (selectedImage != null) {
                  imageCallback.call(selectedImage);
                }
              },
            ),
            SizedBox(height: 8.0.s),
            if (state.displayPhotos) ...[
              ImageSourceWidget(
                text: translate.uploadImage,
                imageSource: ImageSource.gallery,
                permission: Permission.photos,
                imageCallback: imageCallback,
              ),
              SizedBox(height: 8.0.s),
            ],
            if (state.displayCamera)
              ImageSourceWidget(
                text: translate.takeNewPhoto,
                imageSource: ImageSource.camera,
                permission: Permission.camera,
                imageCallback: imageCallback,
              ),
          ],
        );
      },
    );
  }
}

class ImageSourceWidget extends StatelessWidget {
  ImageSourceWidget({
    Key? key,
    required this.imageSource,
    required this.permission,
    required this.text,
    required this.imageCallback,
  }) : super(key: key);

  final ImageSource imageSource;
  final Permission permission;
  final String text;
  final _picker = ImagePicker();
  final ValueChanged<AbiliaFile> imageCallback;

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
                onTap:
                    permissionState.status[permission]?.isPermanentlyDenied ==
                            true
                        ? null
                        : () async => await _getExternalFile(context),
              ),
            ),
            if (permissionState.status[permission]?.isPermanentlyDenied == true)
              Padding(
                padding: EdgeInsets.only(left: 8.0.s),
                child: InfoButton(
                  key: Key('$imageSource$permission'),
                  onTap: () => showViewDialog(
                    useSafeArea: false,
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
      final image = await _picker.pickImage(source: imageSource);
      if (image != null) {
        imageCallback.call(UnstoredAbiliaFile.newFile(File(image.path)));
      }
    } on PlatformException catch (e) {
      _log.warning(e);
    }
  }
}
