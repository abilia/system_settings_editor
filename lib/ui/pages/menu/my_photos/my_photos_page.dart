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
    return BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
      create: (_) => SortableArchiveBloc<ImageArchiveData>(
        initialFolderId: myPhotoFolderId,
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: translate.myPhotos,
            iconData: AbiliaIcons.myPhotos,
            trailing: Padding(
              padding: layout.myPhotos.addPhotoButtonPadding,
              child: _AddPhotoButton(
                myPhotoFolderId: myPhotoFolderId,
                photoCalendarTabIndex: 1,
              ),
            ),
            bottom: AbiliaTabBar(
              tabs: [
                TabItem(
                  translate.allPhotos,
                  AbiliaIcons.myPhotos,
                  key: TestKey.allPhotosTabButton,
                ),
                TabItem(
                  translate.photoCalendar,
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
    Key? key,
    required this.myPhotoFolderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return LibraryPage<ImageArchiveData>.nonSelectable(
      showBottomNavigationBar: false,
      gridCrossAxisCount: layout.myPhotos.crossAxisCount,
      gridChildAspectRatio: layout.myPhotos.childAspectRatio,
      emptyLibraryMessage: translate.noImages,
      libraryItemGenerator: (imageArchive) =>
          ThumbnailPhoto(sortable: imageArchive),
    );
  }
}

class _PhotoCalendarTab extends StatelessWidget {
  final String myPhotoFolderId;

  const _PhotoCalendarTab({
    Key? key,
    required this.myPhotoFolderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
      create: (_) => SortableArchiveBloc<ImageArchiveData>(
        initialFolderId: myPhotoFolderId,
        sortableBloc: BlocProvider.of<SortableBloc>(context),
        visibilityFilter: (imageArchive) =>
            imageArchive.data.isInPhotoCalendar(),
      ),
      child: LibraryPage<ImageArchiveData>.nonSelectable(
        showFolders: false,
        showBottomNavigationBar: false,
        gridCrossAxisCount: layout.myPhotos.crossAxisCount,
        gridChildAspectRatio: layout.myPhotos.childAspectRatio,
        emptyLibraryMessage: translate.noImages,
        libraryItemGenerator: (imageArchive) =>
            ThumbnailPhoto(sortable: imageArchive),
      ),
    );
  }
}

class _AddPhotoButton extends StatefulWidget {
  const _AddPhotoButton({
    Key? key,
    required this.myPhotoFolderId,
    required this.photoCalendarTabIndex,
  }) : super(key: key);

  final String myPhotoFolderId;
  final int photoCalendarTabIndex;

  @override
  State<_AddPhotoButton> createState() => _AddPhotoButtonState();
}

class _AddPhotoButtonState extends State<_AddPhotoButton> {
  TabController? _controller;
  bool includeInPhotoCalendar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_updateOnTabChange);
    super.dispose();
  }

  void _updateTabController() {
    final TabController? newController = DefaultTabController.of(context);
    if (newController != _controller) {
      _controller?.removeListener(_updateOnTabChange);
      _controller = newController;
      _controller?.addListener(_updateOnTabChange);
    }
  }

  void _updateOnTabChange() {
    if (mounted) {
      setState(() {
        includeInPhotoCalendar =
            _controller?.index == widget.photoCalendarTabIndex;
      });
    }
  }

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
                  _addImage(
                    context,
                    selectedImage,
                    time,
                    includeInPhotoCalendar,
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
                  context,
                  selectedImage,
                  time,
                  includeInPhotoCalendar,
                );
              }
            }
          },
          child: const Icon(AbiliaIcons.plus),
        ),
      ),
    );
  }

  void _addImage(
    BuildContext context,
    UnstoredAbiliaFile selectedImage,
    DateTime time,
    bool includeInPhotoCalendar,
  ) {
    context.read<UserFileCubit>().fileAdded(
          selectedImage,
          image: true,
        );
    context.read<SortableBloc>().add(
          PhotoAdded(
            selectedImage.id,
            selectedImage.file.path,
            DateFormat.yMd(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(time),
            includeInPhotoCalendar
                ? widget.myPhotoFolderId
                : context
                    .read<SortableArchiveBloc<ImageArchiveData>>()
                    .state
                    .currentFolderId,
            tags: includeInPhotoCalendar
                ? [ImageArchiveData.photoCalendarTag]
                : [],
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
