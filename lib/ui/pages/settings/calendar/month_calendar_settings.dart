import 'package:seagull/ui/all.dart';

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
