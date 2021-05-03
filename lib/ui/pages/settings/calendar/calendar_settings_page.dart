import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/calendar/day_calendar/day_calendar_settings_page.dart';

class CalendarSettingsPage extends StatelessWidget {
  const CalendarSettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.settings,
          text: Translator.of(context).translate.general,
          navigateTo: CalendarGeneralSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.day,
          text: Translator.of(context).translate.dayCalendar,
          navigateTo: DayCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.week,
          text: Translator.of(context).translate.weekCalendar,
          navigateTo: WeekCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: Translator.of(context).translate.monthCalendar,
          navigateTo: MonthCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.full_screen,
          text: Translator.of(context).translate.activityView,
          navigateTo: ActivityViewSettings(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.new_icon,
          text: Translator.of(context).translate.newActivity,
          navigateTo: NewActivitySettings(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.handi_alarm_vibration,
          text: Translator.of(context).translate.alarmSettings,
          navigateTo: AlarmSettingsPage(),
        ),
      ],
      icon: AbiliaIcons.month,
      title: Translator.of(context).translate.calendar,
    );
  }
}
