import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

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
        child: GridView.count(
          crossAxisSpacing: 7.5.s,
          mainAxisSpacing: 7.s,
          crossAxisCount: 3,
          children: [
            CameraButton(),
            MyPhotosButton(),
            PhotoCalendarButton(),
            CountdownButton(),
            QuickSettingsButton(),
            SettingsButton(),
          ],
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
    return MenuItemButton(
      icon: AbiliaIcons.camera_photo,
      onPressed: () {},
      style: blueButtonStyle,
      text: Translator.of(context).translate.camera,
    );
  }
}

class MyPhotosButton extends StatelessWidget {
  const MyPhotosButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      icon: AbiliaIcons.my_photos,
      onPressed: () {},
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
      onPressed: () {},
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
      data: text.replaceAll('-\n', ''),
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
