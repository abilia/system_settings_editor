import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:sortables/all.dart';

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
        imageCallback: (imageAndName) async {
          await Navigator.of(context).maybePop(imageAndName);
        },
        selectedImage: selectedImage,
        onCancel: () async {
          Navigator.of(context).pop();
          await Navigator.of(context).maybePop();
        },
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }
}

class SelectedImageData {
  final ImageAndName imageAndName;
  final bool fromSearch;

  const SelectedImageData({
    required this.imageAndName,
    required this.fromSearch,
  });
}

class SelectPictureBody extends StatelessWidget {
  final ValueChanged<ImageAndName> imageCallback;
  final AbiliaFile selectedImage;
  final VoidCallback? onCancel;

  const SelectPictureBody({
    required this.imageCallback,
    required this.selectedImage,
    this.onCancel,
    Key? key,
  }) : super(key: key);

  void _imageCallbackAndTrackEvent(SelectedImageData selectedImageData) {
    GetIt.I<SeagullAnalytics>().trackEvent(
      AnalyticsEvents.imageSelected,
      properties: {
        'From search': selectedImageData.fromSearch,
      },
    );
    imageCallback(selectedImageData.imageAndName);
  }

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
                    imageCallback.call(ImageAndName.empty);
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
                onTap: () async => _openImageArchivePage(context),
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
                        ? () async => _openImageArchivePage(
                              context,
                              myPhotos: true,
                              initialFolder: myPhotoFolder.id,
                              header: translate.myPhotos,
                            )
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
                  imageCallback: (image) =>
                      imageCallback(ImageAndName('', image)),
                ),
                SizedBox(height: layout.formPadding.verticalItemDistance),
              ],
              if (photoMenuSettings.displayCamera)
                ImageSourceWidget(
                  key: TestKey.cameraPickField,
                  text: translate.takeNewPhoto,
                  imageSource: ImageSource.camera,
                  permission: Permission.camera,
                  imageCallback: (image) =>
                      imageCallback(ImageAndName('', image)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openImageArchivePage(
    BuildContext context, {
    bool myPhotos = false,
    String initialFolder = '',
    String? header,
  }) async {
    {
      final authProviders = copiedAuthProviders(context);
      final selectedImageData =
          await Navigator.of(context).push<SelectedImageData>(
        PersistentMaterialPageRoute(
          settings: (ImageArchivePage).routeSetting(
            properties: {
              'type': myPhotos ? 'My photos' : 'Image archive',
            },
          ),
          builder: (_) => MultiBlocProvider(
            providers: authProviders,
            child: BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
              create: (_) => SortableArchiveCubit<ImageArchiveData>(
                sortableBloc: BlocProvider.of<SortableBloc>(context),
                initialFolderId: initialFolder,
                myPhotos: myPhotos,
              ),
              child: ImageArchivePage(
                onCancel: onCancel,
                initialFolder: initialFolder,
                header: header,
              ),
            ),
          ),
        ),
      );
      if (selectedImageData != null) {
        _imageCallbackAndTrackEvent(selectedImageData);
      }
    }
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
                  onTap: () async => showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) => PermissionInfoDialog(
                      permission: permission,
                    ),
                    routeSettings: (PermissionInfoDialog).routeSetting(
                      properties: {'permission': permission.toString()},
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
      final image = await _picker.pickImage(source: imageSource);
      if (image != null) {
        imageCallback.call(UnstoredAbiliaFile.newFile(File(image.path)));
      }
    } on PlatformException catch (e) {
      _log.warning(e);
    }
  }
}
