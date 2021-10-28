import 'dart:io';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.menu,
        iconData: AbiliaIcons.appMenu,
      ),
      floatingActionButton: const FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.s, horizontal: 12.s),
        child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, state) {
            return GridView.count(
              crossAxisSpacing: 7.5.s,
              mainAxisSpacing: 7.s,
              crossAxisCount: 3,
              children: [
                if (state.displayMenuCamera) const CameraButton(),
                if (state.displayMenuMyPhotos) const MyPhotosButton(),
                if (state.displayMenuPhotoCalendar) const PhotoCalendarButton(),
                if (state.displayMenuCountdown) const CountdownButton(),
                if (state.displayMenuQuickSettings) const QuickSettingsButton(),
                if (state.displayMenuSettings) const SettingsButton(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CloseButton(),
      ),
    );
  }
}

class CameraButton extends StatelessWidget {
  const CameraButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) => BlocProvider<MyPhotosBloc>(
        create: (_) => MyPhotosBloc(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) => MenuItemButton(
            icon: AbiliaIcons.cameraPhoto,
            onPressed: () async {
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
                  BlocProvider.of<UserFileBloc>(context).add(
                    ImageAdded(selectedImage),
                  );
                  BlocProvider.of<MyPhotosBloc>(context).add(
                    PhotoAdded(
                      selectedImage.id,
                      selectedImage.file.path,
                      DateFormat.yMd(
                              Localizations.localeOf(context).toLanguageTag())
                          .format(time),
                    ),
                  );
                }
              }
            },
            style: blueButtonStyle,
            text: Translator.of(context).translate.camera,
          ),
        ),
      ),
    );
  }
}

class MyPhotosButton extends StatelessWidget {
  const MyPhotosButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.myPhotos,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: const MyPhotosPage(),
          ),
        ),
      ),
      style: blueButtonStyle,
      text: Translator.of(context).translate.myPhotos,
    );
  }
}

class PhotoCalendarButton extends StatelessWidget {
  const PhotoCalendarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.day,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: const PhotoCalendarPage(),
          ),
        ),
      ),
      style: blueButtonStyle,
      text: Translator.of(context).translate.photoCalendar,
    );
  }
}

class CountdownButton extends StatelessWidget {
  const CountdownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.stopWatch,
      onPressed: () {},
      style: pinkButtonStyle,
      text: Translator.of(context).translate.countdown,
    );
  }
}

class QuickSettingsButton extends StatelessWidget {
  const QuickSettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.menuSetup,
      onPressed: () {},
      style: yellowButtonStyle,
      text: Translator.of(context).translate.quickSettingsMenu,
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      style: actionButtonStyleBlack,
      text: Translator.of(context).translate.settings,
      icon: AbiliaIcons.settings,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: const SettingsPage(),
          ),
          settings: const RouteSettings(name: 'SettingsPage'),
        ),
      ),
    );
  }
}

class MenuItemButton extends StatelessWidget {
  final VoidCallback onPressed;
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
                size: 48.s,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
