import 'dart:io';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.menu,
        iconData: AbiliaIcons.app_menu,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.s, horizontal: 12.s),
        child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, state) {
            return GridView.count(
              crossAxisSpacing: 7.5.s,
              mainAxisSpacing: 7.s,
              crossAxisCount: 3,
              children: [
                if (state.displayMenuCamera) CameraButton(),
                if (state.displayMenuMyPhotos) MyPhotosButton(),
                if (state.displayMenuPhotoCalendar) PhotoCalendarButton(),
                if (state.displayMenuCountdown) CountdownButton(),
                if (state.displayMenuQuickSettings) QuickSettingsButton(),
                if (state.displayMenuSettings) SettingsButton(),
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
  const CameraButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, permissionState) => BlocProvider<MyPhotosBloc>(
        create: (_) => MyPhotosBloc(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) => MenuItemButton(
            icon: AbiliaIcons.camera_photo,
            onPressed: () async {
              if (permissionState
                  .status[Permission.camera].isPermanentlyDenied) {
                await showViewDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) =>
                        PermissionInfoDialog(permission: Permission.camera));
              } else {
                final image =
                    await ImagePicker().getImage(source: ImageSource.camera);
                if (image != null) {
                  final selectedImage = SelectedImage.newFile(File(image.path));
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
  const MyPhotosButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.my_photos,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: MyPhotosPage(),
          ),
        ),
      ),
      style: blueButtonStyle,
      text: Translator.of(context).translate.myPhotos,
    );
  }
}

class PhotoCalendarButton extends StatelessWidget {
  const PhotoCalendarButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.day,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: PhotoCalendarPage(),
          ),
        ),
      ),
      style: blueButtonStyle,
      text: Translator.of(context).translate.photoCalendar,
    );
  }
}

class CountdownButton extends StatelessWidget {
  const CountdownButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.stop_watch,
      onPressed: () {},
      style: pinkButtonStyle,
      text: Translator.of(context).translate.countdown,
    );
  }
}

class QuickSettingsButton extends StatelessWidget {
  const QuickSettingsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.menu_setup,
      onPressed: () {},
      style: yellowButtonStyle,
      text: Translator.of(context).translate.quickSettingsMenu,
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key key}) : super(key: key);

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
            child: SettingsPage(),
          ),
          settings: RouteSettings(name: 'SettingsPage'),
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
    Key key,
    @required this.onPressed,
    @required this.text,
    @required this.icon,
    @required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = style.textStyle.resolve({MaterialState.pressed});
    return Tts(
      data: text.singleLine,
      child: AspectRatio(
        aspectRatio: 1,
        child: TextButton(
          style: style,
          onPressed: onPressed,
          child: Column(
            children: [
              SizedBox(
                height: textStyle.fontSize * textStyle.height * 2,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              Icon(
                icon,
                size: 48.s,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}