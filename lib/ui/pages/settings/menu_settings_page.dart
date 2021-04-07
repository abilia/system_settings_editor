import 'package:seagull/ui/all.dart';

class MenuSettingsPage extends StatelessWidget {
  const MenuSettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.app_menu,
      title: Translator.of(context).translate.menu,
    );
  }
}
