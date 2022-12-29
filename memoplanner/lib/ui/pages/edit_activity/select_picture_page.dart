import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:path/path.dart' as p;

final _log = Logger((SelectPicturePage).toString());

class SelectPicturePage extends StatelessWidget {
  final AbiliaFile selectedImage;
  final String? label;

  const SelectPicturePage({
    required this.selectedImage,
    this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: translate.selectImage,
        label: label,
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

  const SelectPictureBody({
    required this.imageCallback,
    required this.selectedImage,
    this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final photoMenuSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.photoMenu);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (selectedImage.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: layout.templates.m1.top),
            child: Column(
              children: [
                SelectedImageWidget(selectedImage: selectedImage),
                SizedBox(height: layout.formPadding.largeVerticalItemDistance),
                RemoveButton(
                  key: TestKey.removePicture,
                  onTap: () {
                    imageCallback.call(AbiliaFile.empty);
                  },
                  icon: Icon(
                    AbiliaIcons.deleteAllClear,
                    color: AbiliaColors.white,
                    size: layout.icon.small,
                  ),
                  text: translate.removeImage,
                ),
                const Divider().pad(dividerPadding),
              ],
            ),
          ),
        Padding(
          padding: layout.templates.m1,
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
                    PersistentMaterialPageRoute(
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
              SizedBox(height: layout.formPadding.verticalItemDistance),
              if (photoMenuSettings.displayMyPhotos) ...[
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
                            final authProviders = copiedAuthProviders(context);
                            final selectedImage =
                                await Navigator.of(context).push<AbiliaFile>(
                              PersistentMaterialPageRoute(
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
                SizedBox(height: layout.formPadding.verticalItemDistance),
              ],
              if (Config.isMPGO && photoMenuSettings.displayLocalImages) ...[
                ImageSourceWidget(
                  key: TestKey.localImagesPickField,
                  text: translate.devicesLocalImages,
                  imageSource: ImageSource.gallery,
                  permission: Permission.photos,
                  imageCallback: imageCallback,
                ),
                SizedBox(height: layout.formPadding.verticalItemDistance),
              ],
              if (photoMenuSettings.displayCamera)
                ImageSourceWidget(
                  key: TestKey.cameraPickField,
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
  }
}

class ImageSourceWidget extends StatelessWidget {
  ImageSourceWidget({
    required this.imageSource,
    required this.permission,
    required this.text,
    required this.imageCallback,
    Key? key,
  }) : super(key: key);

  final ImageSource imageSource;
  final Permission permission;
  final String text;
  final _picker = ImagePicker();
  final ValueChanged<AbiliaFile> imageCallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
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
                padding: EdgeInsets.only(
                  left: layout.formPadding.horizontalItemDistance,
                ),
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

  Future<void> _getExternalFile(BuildContext context) async {
    try {
      final now = context.read<ClockBloc>().state;
      final name = DateFormat('MM-dd-yyyy').format(now);
      final image = await _picker.pickImage(source: imageSource);
      if (image != null) {
        final file = _getFileWithName(image.path, '$name.jpg');
        imageCallback.call(UnstoredAbiliaFile.newFile(file));
      }
    } on PlatformException catch (e) {
      _log.warning(e);
    }
  }
}

File _getFileWithName(String path, String name) {
  final file = File(path);
  final directory = p.dirname(path);
  final newPath = p.join(directory, name);
  file.copySync(newPath);
  file.deleteSync();
  return File(newPath);
}
