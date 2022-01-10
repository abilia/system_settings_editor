import 'dart:io';

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

  const SelectPicturePage({Key? key, required this.selectedImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: translate.selectImage,
      ),
      body: SelectPictureBody(
        imageCallback: (selectedImage) async {
          await Navigator.of(context).maybePop(selectedImage);
        },
        selectedImage: selectedImage,
        onCancel: () => {
          Navigator.of(context)
            ..pop()
            ..maybePop()
        },
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }
}

class SelectPictureBody extends StatelessWidget {
  final ValueChanged<AbiliaFile> imageCallback;
  final AbiliaFile selectedImage;
  final VoidCallback? onCancel;

  const SelectPictureBody(
      {Key? key,
      required this.imageCallback,
      required this.selectedImage,
      this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
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
                            imageCallback.call(AbiliaFile.empty);
                          },
                          icon: Icon(
                            AbiliaIcons.deleteAllClear,
                            color: AbiliaColors.white,
                            size: layout.iconSize.small,
                          ),
                          text: translate.removeImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
              child: Column(
                children: [
                  PickField(
                    key: TestKey.imageArchiveButton,
                    leading: const Icon(AbiliaIcons.folder),
                    text: Text(translate.imageArchive),
                    onTap: () async {
                      final authProviders = copiedAuthProviders(context);
                      final selectedImage =
                          await Navigator.of(context).push<AbiliaFile>(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: authProviders,
                            child: ImageArchivePage(onCancel: onCancel),
                          ),
                        ),
                      );
                      if (selectedImage != null) {
                        imageCallback.call(selectedImage);
                      }
                    },
                  ),
                  SizedBox(height: 8.0.s),
                  BlocSelector<SortableBloc, SortableState,
                      Sortable<ImageArchiveData>?>(
                    selector: (state) => state is SortablesLoaded
                        ? state.sortables.getMyPhotosFolder()
                        : null,
                    builder: (context, myPhotoFolder) => PickField(
                      key: TestKey.myPhotosButton,
                      leading: const Icon(AbiliaIcons.folder),
                      text: Text(translate.myPhotos),
                      onTap: (myPhotoFolder != null)
                          ? () async {
                              final authProviders =
                                  copiedAuthProviders(context);
                              final selectedImage =
                                  await Navigator.of(context).push<AbiliaFile>(
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: authProviders,
                                    child: ImageArchivePage(
                                      onCancel: onCancel,
                                      initialFolder: myPhotoFolder.id,
                                      header: translate.myPhotos,
                                    ),
                                  ),
                                ),
                              );
                              if (selectedImage != null) {
                                imageCallback.call(selectedImage);
                              }
                            }
                          : null,
                    ),
                  ),
                  SizedBox(height: 8.0.s),
                  if (Config.isMPGO && state.displayPhotos) ...[
                    ImageSourceWidget(
                      text: translate.devicesLocalImages,
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
              ),
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
                    builder: (context) => PermissionInfoDialog(
                      permission: permission,
                    ),
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
