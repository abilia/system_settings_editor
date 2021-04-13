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
            padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
            child:
                BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
              builder: (context, state) {
                return Column(
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
                              child: const ImageArchivePage(),
                            ),
                          ),
                        );
                        if (selectedImage != null) {
                          await Navigator.of(context).maybePop(selectedImage);
                        }
                      },
                    ),
                    SizedBox(height: 8.0.s),
                    if (state.displayPhotos) ...[
                      ImageSourceWidget(
                        text: translate.myPhotos,
                        imageSource: ImageSource.gallery,
                        permission: Platform.isAndroid
                            ? Permission.storage
                            : Permission.photos,
                      ),
                      SizedBox(height: 8.0.s),
                    ],
                    if (state.displayCamera)
                      ImageSourceWidget(
                        text: translate.takeNewPhoto,
                        imageSource: ImageSource.camera,
                        permission: Permission.camera,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
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
