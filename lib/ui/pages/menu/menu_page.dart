import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MenuAppBar(),
      floatingActionButton: const FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      body: Padding(
        padding: layout.menuPage.padding,
        child: BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
            MenuSettings>(
          selector: (state) => state.settings.menu,
          builder: (context, menu) {
            return GridView.count(
              crossAxisSpacing: layout.menuPage.crossAxisSpacing,
              mainAxisSpacing: layout.menuPage.mainAxisSpacing,
              crossAxisCount: layout.menuPage.crossAxisCount,
              children: [
                if (menu.showCamera) const CameraButton(),
                if (menu.showPhotos) const MyPhotosButton(),
                if (menu.photoCalendarEnabled) const PhotoCalendarButton(),
                if (menu.quickSettingsEnabled) const QuickSettingsButton(),
                if (menu.showBasicTemplates) const BasicTemplatesButton(),
                if (menu.showSettings) const SettingsButton(),
              ],
            );
          },
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
              final image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                final selectedImage =
                    UnstoredAbiliaFile.newFile(File(image.path));
                BlocProvider.of<UserFileCubit>(context).fileAdded(
                  selectedImage,
                  image: true,
                );
                BlocProvider.of<SortableBloc>(context).add(
                  PhotoAdded(
                    selectedImage.id,
                    selectedImage.file.path,
                    DateFormat.yMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(context.read<ClockBloc>().state),
                    myPhotoFolderId,
                  ),
                );
              }
            }
          },
          style: blueButtonStyle,
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
        style: blueButtonStyle,
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
        final authProviders = copiedAuthProviders(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: authProviders,
              child: const PhotoCalendarPage(),
            ),
          ),
        );
      },
      style: blueButtonStyle,
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
      style: yellowButtonStyle,
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
              style: blackButtonStyle,
              text: name,
              icon: AbiliaIcons.settings,
              onPressed: () async {
                final accessGranted = await codeProtectAccess(
                  context,
                  restricted: (codeSettings) => codeSettings.protectSettings,
                  name: name,
                );
                if (accessGranted) {
                  final authProviders = copiedAuthProviders(context);
                  Navigator.of(context).push(
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
                top: layout.menuPage.menuItemButton.orangeDotInset,
                right: layout.menuPage.menuItemButton.orangeDotInset,
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
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = style.textStyle?.resolve({MaterialState.pressed});
    final fontSize = textStyle?.fontSize;
    final textHeight = textStyle?.height;
    return Tts.data(
      data: text.singleLine,
      child: AspectRatio(
        aspectRatio: 1,
        child: TextButton(
          style: style,
          onPressed: onPressed,
          child: Column(
            children: [
              SizedBox(
                height: fontSize != null && textHeight != null
                    ? fontSize * textHeight * 2
                    : null,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                size: layout.menuPage.menuItemButton.size,
              ),
              const Spacer(),
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
      style: blackButtonStyle,
      text: Translator.of(context).translate.basicTemplates,
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
                child: const BasicTemplatesPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
