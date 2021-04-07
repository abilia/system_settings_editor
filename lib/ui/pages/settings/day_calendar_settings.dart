import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';

class DayCalendarSettings extends StatelessWidget {
  const DayCalendarSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.day,
      title: Translator.of(context).translate.dayCalendar,
    );
  }
}
