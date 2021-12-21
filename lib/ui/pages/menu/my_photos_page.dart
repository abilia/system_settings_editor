import 'dart:io';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MyPhotosPage extends StatelessWidget {
  final String myPhotoFolderId;

  const MyPhotosPage({
    required this.myPhotoFolderId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return LibraryPage<ImageArchiveData>.nonSelectable(
      appBar: AbiliaAppBar(
        title: translate.myPhotos,
        iconData: AbiliaIcons.myPhotos,
        trailing: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.s),
          child: const AddPhotoButton(),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CloseButton(),
      ),
      initialFolder: myPhotoFolderId,
      emptyLibraryMessage: translate.noImages,
      libraryItemGenerator: (imageArchive) =>
          FullscreenViewablePhoto(sortable: imageArchive),
      libraryFolderGenerator: (imageArchive) => LibraryFolder(
        title: imageArchive.data.title(),
        fileId: imageArchive.data.folderFileId(),
        filePath: imageArchive.data.folderFilePath(),
      ),
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, permissionState) => BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) => IconActionButtonLight(
            onPressed: () async {
              if (Config.isMP) {
                if (permissionState
                        .status[Permission.camera]?.isPermanentlyDenied ==
                    true) {
                  await showViewDialog(
                      useSafeArea: false,
                      context: context,
                      builder: (context) => const PermissionInfoDialog(
                          permission: Permission.camera));
                } else {
                  final image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    final selectedImage =
                        UnstoredAbiliaFile.newFile(File(image.path));
                    _addImage(context, selectedImage, time);
                  }
                }
              } else {
                final selectedImage =
                    await Navigator.of(context).push<UnstoredAbiliaFile>(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: const ImportPicturePage(),
                    ),
                  ),
                );
                if (selectedImage != null) {
                  _addImage(context, selectedImage, time);
                }
              }
            },
            child: const Icon(AbiliaIcons.plus),
          ),
        ),
      );

  void _addImage(
      BuildContext context, UnstoredAbiliaFile selectedImage, DateTime time) {
    BlocProvider.of<UserFileBloc>(context).add(ImageAdded(selectedImage));
    context.read<SortableBloc>().add(
          PhotoAdded(
            selectedImage.id,
            selectedImage.file.path,
            DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
                .format(time),
            context
                .read<SortableArchiveBloc<ImageArchiveData>>()
                .state
                .currentFolderId,
          ),
        );
  }
}

class FullscreenViewablePhoto extends StatelessWidget {
  const FullscreenViewablePhoto({
    required this.sortable,
    Key? key,
  }) : super(key: key);
  final Sortable<ImageArchiveData> sortable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async => await showViewDialog<bool>(
        useSafeArea: false,
        context: context,
        builder: (_) {
          return FullscreenImageDialog(
            fileId: sortable.data.fileId,
            filePath: sortable.data.file,
          );
        },
      ),
      child: Photo(sortable: sortable),
    );
  }
}

class Photo extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;

  const Photo({
    required this.sortable,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageArchiveData = sortable.data;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: imageArchiveData.name,
        image: imageArchiveData.fileId.isNotEmpty ||
            imageArchiveData.file.isNotEmpty,
        button: true,
      ),
      child: Container(
        decoration: boxDecoration,
        padding: EdgeInsets.all(4.0.s),
        child: Column(
          children: [
            Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: FadeInAbiliaImage(
                fit: BoxFit.cover,
                width: double.infinity,
                imageFileId: imageId,
                imageFilePath: iconPath,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
