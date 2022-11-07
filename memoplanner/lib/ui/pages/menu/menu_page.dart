import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
          child: Wrap(
            spacing: layout.menuPage.crossAxisSpacing,
            runSpacing: layout.menuPage.mainAxisSpacing,
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
              );
            } else {
              final userFileCubit = context.read<UserFileCubit>();
              final sortableBloc = context.read<SortableBloc>();
              final name = DateFormat.yMd(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(context.read<ClockBloc>().state);
              final image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                final selectedImage =
                    UnstoredAbiliaFile.newFile(File(image.path));
                userFileCubit.fileAdded(
                  selectedImage,
                  image: true,
                );
                sortableBloc.add(
                  PhotoAdded(
                    selectedImage.id,
                    selectedImage.file.path,
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
            ? () {
                final authProviders = copiedAuthProviders(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: MyPhotosPage(myPhotoFolderId: myPhotoFolderId),
                    ),
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
        DefaultTabController.of(context)?.index = photoAlbumTabIndex;
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
      onPressed: () {
        final authProviders = copiedAuthProviders(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: authProviders,
              child: const QuickSettingsPage(),
            ),
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
    return BlocSelector<PermissionCubit, PermissionState, bool>(
      selector: (state) => state.importantPermissionMissing,
      builder: (context, importantPermissionMissing) {
        final name = Translator.of(context).translate.settings;
        return Stack(
          children: [
            MenuItemButton(
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
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: const SettingsPage(),
                      ),
                      settings: const RouteSettings(name: 'SettingsPage'),
                    ),
                  );
                }
              },
            ),
            if (importantPermissionMissing)
              Positioned(
                top: layout.menuPage.buttons.orangeDotInset,
                right: layout.menuPage.buttons.orangeDotInset,
                child: const OrangeDot(),
              ),
          ],
        );
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
      child: SizedBox(
        width: layout.menuPage.buttons.size,
        height: layout.menuPage.buttons.size,
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
      onPressed: () {
        final authProviders = copiedAuthProviders(context);
        Navigator.of(context).push(
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
          ),
        );
      },
    );
  }
}
