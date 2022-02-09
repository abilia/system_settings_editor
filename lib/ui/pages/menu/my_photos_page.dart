import 'dart:io';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MyPhotosPage extends StatelessWidget {
  final String myPhotoFolderId;

  const MyPhotosPage({
    required this.myPhotoFolderId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: translate.myPhotos,
          iconData: AbiliaIcons.myPhotos,
          trailing: Padding(
            padding: layout.myPhotos.addPhotoButtonPadding,
            child: const AddPhotoButton(),
          ),
          bottom: AbiliaTabBar(
            tabs: [
              TabItem(translate.allPhotos, AbiliaIcons.myPhotos),
              TabItem(translate.photoCalendar, AbiliaIcons.photoCalendar),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllPhotos(myPhotoFolderId: myPhotoFolderId),
            _PhotoCalendar(myPhotoFolderId: myPhotoFolderId),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(
          backNavigationWidget: CloseButton(),
        ),
      ),
    );
  }
}

class _AllPhotos extends StatelessWidget {
  final String myPhotoFolderId;

  const _AllPhotos({
    Key? key,
    required this.myPhotoFolderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return LibraryPage<ImageArchiveData>.nonSelectable(
      showAppBar: false,
      showBottomNavigationBar: false,
      gridCrossAxisCount: layout.myPhotos.crossAxisCount,
      gridChildAspectRatio: layout.myPhotos.childAspectRatio,
      initialFolder: myPhotoFolderId,
      emptyLibraryMessage: translate.noImages,
      libraryItemGenerator: (imageArchive) =>
          ThumbnailPhoto(sortable: imageArchive),
    );
  }
}

class _PhotoCalendar extends StatelessWidget {
  final String myPhotoFolderId;

  const _PhotoCalendar({
    Key? key,
    required this.myPhotoFolderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return LibraryPage<ImageArchiveData>.nonSelectable(
      showFolders: false,
      showAppBar: false,
      showBottomNavigationBar: false,
      gridCrossAxisCount: layout.myPhotos.crossAxisCount,
      gridChildAspectRatio: layout.myPhotos.childAspectRatio,
      initialFolder: myPhotoFolderId,
      emptyLibraryMessage: translate.noImages,
      visibilityFilter: (imageArchive) => imageArchive.data.isInPhotoCalendar(),
      libraryItemGenerator: (imageArchive) =>
          ThumbnailPhoto(sortable: imageArchive),
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
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
              final authProviders = copiedAuthProviders(context);
              final selectedImage =
                  await Navigator.of(context).push<UnstoredAbiliaFile>(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
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
  }

  void _addImage(
      BuildContext context, UnstoredAbiliaFile selectedImage, DateTime time) {
    context.read<UserFileCubit>().fileAdded(
          selectedImage,
          image: true,
        );
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

class PhotoPage extends StatelessWidget {
  const PhotoPage({
    Key? key,
    required this.sortable,
  }) : super(key: key);

  final Sortable<ImageArchiveData> sortable;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
      create: (_) => SortableArchiveBloc<ImageArchiveData>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
          SortableArchiveState<ImageArchiveData>>(
        builder: (context, archiveState) {
          final allById = archiveState.allById;
          final photoSortable = allById[sortable.id];
          assert(photoSortable != null, 'Sortable with the same ID not found');
          final bool isInPhotoCalendar =
              photoSortable?.data.isInPhotoCalendar() ??
                  sortable.data.isInPhotoCalendar();

          return Scaffold(
            appBar: AbiliaAppBar(
              title: photoSortable?.data.name ?? sortable.data.name,
              label: translate.myPhotos,
              iconData: AbiliaIcons.myPhotos,
            ),
            body: Padding(
              padding: layout.myPhotos.fullScreenImagePadding,
              child: Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        layout.myPhotos.fullScreenImageBorderRadius,
                      ),
                      child: FullScreenImage(
                        backgroundDecoration: const BoxDecoration(),
                        fileId:
                            photoSortable?.data.fileId ?? sortable.data.fileId,
                        filePath:
                            photoSortable?.data.file ?? sortable.data.file,
                        tightMode: true,
                      ),
                    ),
                    if (isInPhotoCalendar)
                      const Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: PhotoCalendarSticker(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: SizedBox(
                height: layout.toolbar.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextAndOrIconActionButtonLight(
                      isInPhotoCalendar ? translate.remove : translate.add,
                      isInPhotoCalendar
                          ? AbiliaIcons.noPhotoCalendar
                          : AbiliaIcons.photoCalendar,
                      onPressed: () {
                        addOrRemovePhotoFromPhotoCalendar(
                          context,
                          remove: isInPhotoCalendar,
                          sortable: photoSortable ?? sortable,
                        );
                      },
                    ),
                    TextAndOrIconActionButtonLight(
                      translate.delete,
                      AbiliaIcons.deleteAllClear,
                      onPressed: () {},
                    ),
                    TextAndOrIconActionButtonLight(
                      translate.close,
                      AbiliaIcons.navigationPrevious,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void addOrRemovePhotoFromPhotoCalendar(
    BuildContext context, {
    required bool remove,
    required Sortable<ImageArchiveData> sortable,
  }) async {
    final translate = Translator.of(context).translate;

    final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => ViewDialog(
        heading: AppBarHeading(
          text: translate.photoCalendar,
          iconData: AbiliaIcons.photoCalendar,
        ),
        body: Tts(
          child: Text(
            remove
                ? translate.removeFromPhotoCalendarQuestion
                : translate.addToPhotoCalendarQuestion,
          ),
        ),
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: GreenButton(
          text: remove ? translate.remove : translate.add,
          icon: AbiliaIcons.ok,
          onPressed: () => Navigator.of(context).maybePop(true),
        ),
      ),
    );
    if (result == true) {
      Set<String> updatedTags = {};
      if (remove) {
        updatedTags
          ..addAll([...sortable.data.tags])
          ..remove(ImageArchiveData.photoCalendarTag);
      } else {
        updatedTags.addAll(
          [...sortable.data.tags, ImageArchiveData.photoCalendarTag],
        );
      }
      final updatedSortable = sortable.copyWith(
          data: sortable.data.copyWith(tags: updatedTags.toList()));
      BlocProvider.of<SortableBloc>(context)
          .add(SortableUpdated(updatedSortable));
    }
  }
}

class ThumbnailPhoto extends StatelessWidget {
  final Sortable<ImageArchiveData> sortable;

  const ThumbnailPhoto({
    required this.sortable,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageArchiveData = sortable.data;
    final name = imageArchiveData.name;
    final imageId = imageArchiveData.fileId;
    final iconPath = imageArchiveData.file;
    final authProviders = copiedAuthProviders(context);

    return InkWell(
      borderRadius: boxDecoration.borderRadius?.resolve(null),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: authProviders,
              child: PhotoPage(
                sortable: sortable,
              ),
            ),
          ),
        );
      },
      child: Tts.fromSemantics(
        SemanticsProperties(
          label: imageArchiveData.name,
          image: imageArchiveData.fileId.isNotEmpty ||
              imageArchiveData.file.isNotEmpty,
          button: true,
        ),
        child: Stack(
          children: [
            Container(
              decoration: boxDecoration,
              child: Column(
                children: [
                  Padding(
                    padding: layout.dataItem.picture.titlePadding,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: layout.dataItem.picture.imagePadding,
                      child: FadeInAbiliaImage(
                        fit: BoxFit.cover,
                        width: double.infinity,
                        imageFileId: imageId,
                        imageFilePath: iconPath,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (sortable.data.isInPhotoCalendar())
              const Align(
                alignment: Alignment.bottomLeft,
                child: PhotoCalendarSticker(),
              ),
          ],
        ),
      ),
    );
  }
}

class PhotoCalendarSticker extends StatelessWidget {
  const PhotoCalendarSticker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(layout.dataItem.borderRadius);
    return Container(
      decoration: BoxDecoration(
        color: AbiliaColors.blue,
        borderRadius: BorderRadius.only(bottomLeft: radius, topRight: radius),
      ),
      height: layout.dataItem.picture.stickerSize.height,
      width: layout.dataItem.picture.stickerSize.width,
      child: Icon(
        AbiliaIcons.photoCalendar,
        color: AbiliaColors.white,
        size: layout.dataItem.picture.stickerIconSize,
      ),
    );
  }
}
