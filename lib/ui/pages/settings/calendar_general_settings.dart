import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.settings,
      title: Translator.of(context).translate.general,
    );
  }
}
