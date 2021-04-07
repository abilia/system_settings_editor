import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class NewActivitySettings extends StatelessWidget {
  const NewActivitySettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
        widgets: [],
        icon: AbiliaIcons.new_icon,
        title: Translator.of(context).translate.newActivity);
  }
}
