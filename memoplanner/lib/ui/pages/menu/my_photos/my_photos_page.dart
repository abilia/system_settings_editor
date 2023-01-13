import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class MyPhotosPage extends StatelessWidget {
  final String myPhotoFolderId;

  const MyPhotosPage({
    required this.myPhotoFolderId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
      create: (_) => SortableArchiveCubit<ImageArchiveData>(
        initialFolderId: myPhotoFolderId,
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: translate.myPhotos,
            iconData: AbiliaIcons.myPhotos,
            bottom: AbiliaTabBar(
              tabs: [
                TabItem(
                  translate.allPhotos.singleLine,
                  AbiliaIcons.myPhotos,
                  key: TestKey.allPhotosTabButton,
                ),
                TabItem(
                  translate.photoCalendar.singleLine,
                  AbiliaIcons.photoCalendar,
                  key: TestKey.photoCalendarTabButton,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _AllPhotosTab(
                key: TestKey.allPhotosTab,
                myPhotoFolderId: myPhotoFolderId,
              ),
              _PhotoCalendarTab(
                key: TestKey.photoCalendarTab,
                myPhotoFolderId: myPhotoFolderId,
              ),
            ],
          ),
          floatingActionButton: _AddPhotoButton(
            myPhotoFolderId: myPhotoFolderId,
            photoCalendarTabIndex: 1,
          ),
          bottomNavigationBar: const BottomNavigation(
            backNavigationWidget: CloseButton(),
          ),
        ),
      ),
    );
  }
}

class _AllPhotosTab extends StatelessWidget {
  final String myPhotoFolderId;

  const _AllPhotosTab({
    required this.myPhotoFolderId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LibraryPage<ImageArchiveData>.nonSelectable(
      showBottomNavigationBar: false,
      gridCrossAxisCount: layout.myPhotos.crossAxisCount,
      gridChildAspectRatio: layout.myPhotos.childAspectRatio,
      emptyLibraryMessage: Translator.of(context).translate.noImages,
      libraryItemGenerator: (imageArchive) =>
          ThumbnailPhoto(sortable: imageArchive),
    );
  }
}

class _PhotoCalendarTab extends StatelessWidget {
  final String myPhotoFolderId;

  const _PhotoCalendarTab({
    required this.myPhotoFolderId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
      create: (_) => SortableArchiveCubit<ImageArchiveData>(
        initialFolderId: myPhotoFolderId,
        sortableBloc: BlocProvider.of<SortableBloc>(context),
        visibilityFilter: (imageArchive) =>
            imageArchive.data.isInPhotoCalendar(),
        showFolders: false,
      ),
      child: LibraryPage<ImageArchiveData>.nonSelectable(
        showBottomNavigationBar: false,
        gridCrossAxisCount: layout.myPhotos.crossAxisCount,
        gridChildAspectRatio: layout.myPhotos.childAspectRatio,
        emptyLibraryMessage: Translator.of(context).translate.noImages,
        libraryItemGenerator: (imageArchive) =>
            ThumbnailPhoto(sortable: imageArchive),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({
    required this.myPhotoFolderId,
    required this.photoCalendarTabIndex,
    Key? key,
  }) : super(key: key);

  final String myPhotoFolderId;
  final int photoCalendarTabIndex;

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context)!;
    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, permissionState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) => AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final includeInPhotoCalendar =
                  tabController.index == photoCalendarTabIndex;
              return TextAndOrIconActionButtonBlack(
                Translator.of(context).translate.newText,
                AbiliaIcons.plus,
                onPressed: () async {
                  final userFileCubit = context.read<UserFileCubit>();
                  final sortableBloc = context.read<SortableBloc>();
                  final name = getImageNameFromDate(time);
                  final currentFolderId = context
                      .read<SortableArchiveCubit<ImageArchiveData>>()
                      .state
                      .currentFolderId;
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
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (image != null) {
                        final selectedImage =
                            UnstoredAbiliaFile.newFile(File(image.path));
                        _addImage(
                          userFileCubit: userFileCubit,
                          sortableBloc: sortableBloc,
                          selectedImage: selectedImage,
                          name: name,
                          currentFolderId: currentFolderId,
                          includeInPhotoCalendar: includeInPhotoCalendar,
                        );
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
                      _addImage(
                        userFileCubit: userFileCubit,
                        selectedImage: selectedImage,
                        currentFolderId: currentFolderId,
                        name: name,
                        includeInPhotoCalendar: includeInPhotoCalendar,
                        sortableBloc: sortableBloc,
                      );
                    }
                  }
                },
              );
            }),
      ),
    );
  }

  void _addImage({
    required UserFileCubit userFileCubit,
    required SortableBloc sortableBloc,
    required UnstoredAbiliaFile selectedImage,
    required String name,
    required String currentFolderId,
    required bool includeInPhotoCalendar,
  }) {
    userFileCubit.fileAdded(
      selectedImage,
      image: true,
    );
    sortableBloc.add(
      PhotoAdded(
        selectedImage.id,
        name,
        includeInPhotoCalendar ? myPhotoFolderId : currentFolderId,
        tags: {if (includeInPhotoCalendar) ImageArchiveData.photoCalendarTag},
      ),
    );
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
    return InkWell(
      borderRadius: boxDecoration.borderRadius?.resolve(null),
      onTap: () {
        final authProviders = copiedAuthProviders(context);
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
                      imageArchiveData.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(height: 1),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: layout.dataItem.picture.imagePadding,
                      child: FadeInAbiliaImage(
                        fit: BoxFit.cover,
                        width: double.infinity,
                        imageFileId: imageArchiveData.fileId,
                        imageFilePath: imageArchiveData.file,
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
