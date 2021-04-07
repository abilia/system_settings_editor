import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/image_picker_settings_page.dart';
import 'package:seagull/ui/pages/settings/menu_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    CalendarPickField(),
    FunctionSettingsPickField(),
    ImagePickerSettingsPickField(),
    MenuSettingsPickField(),
    CountdownSettingsPickField(),
    SystemSettingsPickField(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.settings,
        iconData: AbiliaIcons.settings,
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.0.s),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: BackButton(),
      ),
    );
  }
}

class CalendarPickField extends StatelessWidget {
  const CalendarPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.month),
        text: Text(Translator.of(context).translate.calendar),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: CalendarSettingsPage(),
            ),
          ),
        ),
      );
}

class FunctionSettingsPickField extends StatelessWidget {
  const FunctionSettingsPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.menu_setup),
        text: Text(Translator.of(context).translate.functions),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: FunctionSettingsPage(),
            ),
          ),
        ),
      );
}

class ImagePickerSettingsPickField extends StatelessWidget {
  const ImagePickerSettingsPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.my_photos),
        text: Text(Translator.of(context).translate.imagePicker),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: ImagePickerSettingsPage(),
            ),
          ),
        ),
      );
}

class MenuSettingsPickField extends StatelessWidget {
  const MenuSettingsPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.app_menu),
        text: Text(Translator.of(context).translate.menu),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: MenuSettingsPage(),
            ),
          ),
        ),
      );
}

class MenuItemPickField extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget navigateTo;
  const MenuItemPickField({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.navigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(icon),
        text: Text(text),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: MenuSettingsPage(),
            ),
          ),
        ),
      );
}

class CountdownSettingsPickField extends StatelessWidget {
  const CountdownSettingsPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.stop_watch),
        text: Text(Translator.of(context).translate.countdown),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: CountdownSettingsPage(),
            ),
          ),
        ),
      );
}

class SystemSettingsPickField extends StatelessWidget {
  const SystemSettingsPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.technical_settings),
        text: Text(Translator.of(context).translate.system),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: SystemSettingsPage(),
            ),
          ),
        ),
      );
}
