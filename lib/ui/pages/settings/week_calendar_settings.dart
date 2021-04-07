import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class WeekCalendarSettings extends StatelessWidget {
  const WeekCalendarSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.week,
      title: Translator.of(context).translate.weekCalendar,
    );
  }
}
