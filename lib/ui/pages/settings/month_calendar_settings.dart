import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class MonthCalendarSettings extends StatelessWidget {
  const MonthCalendarSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.month,
      title: Translator.of(context).translate.monthCalendar,
    );
  }
}
