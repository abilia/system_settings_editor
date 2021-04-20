import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/activity_view_settings.dart';
import 'package:seagull/ui/pages/settings/alarm_settings.dart';
import 'package:seagull/ui/pages/settings/calendar_general_settings.dart';
import 'package:seagull/ui/pages/settings/day_calendar_settings_page.dart';
import 'package:seagull/ui/pages/settings/month_calendar_settings.dart';
import 'package:seagull/ui/pages/settings/new_activity_settings.dart';
import 'package:seagull/ui/pages/settings/settings_base_page.dart';
import 'package:seagull/ui/pages/settings/week_calendar_settings.dart';

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
          navigateTo: WeekCalendarSettings(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: Translator.of(context).translate.monthCalendar,
          navigateTo: MonthCalendarSettings(),
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
          icon: AbiliaIcons.technical_settings,
          text: Translator.of(context).translate.alarmSettings,
          navigateTo: AlarmSettingsPage(),
        ),
      ],
      icon: AbiliaIcons.month,
      title: Translator.of(context).translate.calendar,
    );
  }
}
