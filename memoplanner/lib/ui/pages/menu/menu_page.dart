import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:sortables/bloc/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.menu);
    return Scaffold(
      appBar: const MenuAppBar(),
      floatingActionButton: const FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      body: Padding(
        padding: layout.templates.m2,
        child: Align(
          alignment: Alignment.topCenter,
          child: GridView.count(
            primary: false,
            crossAxisSpacing: layout.menuPage.buttons.spacing,
            mainAxisSpacing: layout.menuPage.buttons.spacing,
            crossAxisCount: 3,
            children: [
              if (menuSettings.showCamera) const CameraButton(),
              if (menuSettings.showPhotos) const MyPhotosButton(),
              if (menuSettings.photoCalendarEnabled)
                const PhotoCalendarButton(),
              if (menuSettings.quickSettingsEnabled)
                const QuickSettingsButton(),
              if (menuSettings.showTemplates) const BasicTemplatesButton(),
              if (menuSettings.showSettings) const SettingsButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraButton extends StatelessWidget {
  const CameraButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionCubit, PermissionState, bool>(
      selector: (state) =>
          state.status[Permission.camera]?.isPermanentlyDenied == true,
      builder: (context, cameraIsPermanentlyDenied) =>
          BlocSelector<SortableBloc, SortableState, String>(
        selector: (state) => state is SortablesLoaded
            ? state.sortables.getMyPhotosFolder()?.id ?? ''
            : '',
        builder: (context, myPhotoFolderId) => MenuItemButton(
          icon: AbiliaIcons.cameraPhoto,
          onPressed: () async {
            if (cameraIsPermanentlyDenied) {
              await showViewDialog(
                useSafeArea: false,
                context: context,
                builder: (context) => const PermissionInfoDialog(
                  permission: Permission.camera,
                ),
                routeSettings: (PermissionInfoDialog).routeSetting(
                  properties: {'permission': Permission.camera.toString()},
                ),
              );
            } else {
              final userFileBloc = context.read<UserFileBloc>();
              final sortableBloc = context.read<SortableBloc>();
              final now = context.read<ClockBloc>().state;
              final name = DateFormat.yMd(Platform.localeName).format(now);
              final image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                final selectedImage =
                    UnstoredAbiliaFile.newFile(File(image.path));
                userFileBloc.add(
                  FileAdded(
                    selectedImage,
                    isImage: true,
                  ),
                );
                sortableBloc.add(
                  PhotoAdded(
                    selectedImage.id,
                    name,
                    myPhotoFolderId,
                  ),
                );
              }
            }
          },
          style: blueMenuButtonStyle,
          text: Translator.of(context).translate.camera,
        ),
      ),
    );
  }
}

class MyPhotosButton extends StatelessWidget {
  const MyPhotosButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SortableBloc, SortableState, String?>(
      selector: (state) => state is SortablesLoaded
          ? state.sortables.getMyPhotosFolder()?.id
          : null,
      builder: (context, myPhotoFolderId) => MenuItemButton(
        icon: AbiliaIcons.myPhotos,
        onPressed: myPhotoFolderId != null
            ? () async {
                final authProviders = copiedAuthProviders(context);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: MyPhotosPage(myPhotoFolderId: myPhotoFolderId),
                    ),
                    settings: (MyPhotosPage).routeSetting(),
                  ),
                );
              }
            : null,
        style: blueMenuButtonStyle,
        text: Translator.of(context).translate.myPhotos,
      ),
    );
  }
}

class PhotoCalendarButton extends StatelessWidget {
  const PhotoCalendarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.photoCalendar,
      onPressed: () {
        final settings = context.read<MemoplannerSettingsBloc>().state;
        final photoAlbumTabIndex =
            settings.functions.display.photoAlbumTabIndex;
        DefaultTabController.of(context).index = photoAlbumTabIndex;
      },
      style: blueMenuButtonStyle,
      text: Translator.of(context).translate.photoCalendar,
    );
  }
}

class QuickSettingsButton extends StatelessWidget {
  const QuickSettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.quickSettings,
      onPressed: () async {
        final authProviders = copiedAuthProviders(context);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: authProviders,
              child: const QuickSettingsPage(),
            ),
            settings: (QuickSettingsPage).routeSetting(),
          ),
        );
      },
      style: yellowMenuButtonStyle,
      text: Translator.of(context).translate.quickSettingsMenu,
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = Translator.of(context).translate.settings;
    return MenuItemButton(
      style: blackMenuButtonStyle,
      text: name,
      icon: AbiliaIcons.settings,
      onPressed: () async {
        final navigator = Navigator.of(context);
        final authProviders = copiedAuthProviders(context);
        final accessGranted = await codeProtectAccess(
          context,
          restricted: (codeSettings) => codeSettings.protectSettings,
          name: name,
        );
        if (accessGranted) {
          await navigator.push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: const SettingsPage(),
              ),
              settings: (SettingsPage).routeSetting(
                properties: {
                  'fromHidden': false,
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class MenuItemButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonStyle style;
  final IconData icon;

  const MenuItemButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: text.singleLine,
      child: TextButton(
        style: style,
        onPressed: onPressed,
        child: Padding(
          padding: layout.menuPage.buttons.padding,
          child: Column(
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Icon(
                icon,
                size: layout.menuPage.buttons.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BasicTemplatesButton extends StatelessWidget {
  const BasicTemplatesButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      style: blackMenuButtonStyle,
      text: Translator.of(context).translate.templates,
      icon: AbiliaIcons.favoritesShow,
      onPressed: () async {
        final authProviders = copiedAuthProviders(context);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: authProviders,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        SortableArchiveCubit<BasicActivityData>(
                      sortableBloc: BlocProvider.of<SortableBloc>(context),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => SortableArchiveCubit<BasicTimerData>(
                      sortableBloc: BlocProvider.of<SortableBloc>(context),
                    ),
                  ),
                ],
                child: const TemplatesPage(),
              ),
            ),
            settings: (TemplatesPage).routeSetting(),
          ),
        );
      },
    );
  }
}
