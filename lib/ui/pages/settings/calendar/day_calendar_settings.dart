import 'package:seagull/ui/all.dart';

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
