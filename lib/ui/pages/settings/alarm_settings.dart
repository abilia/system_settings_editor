import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.technical_settings,
      title: Translator.of(context).translate.alarmSettings,
    );
  }
}
