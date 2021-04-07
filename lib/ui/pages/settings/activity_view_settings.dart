import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class ActivityViewSettings extends StatelessWidget {
  const ActivityViewSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.full_screen,
      title: Translator.of(context).translate.activityView,
    );
  }
}
