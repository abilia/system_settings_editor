import 'package:seagull/ui/all.dart';

class CalendarSettingsPage extends StatelessWidget {
  const CalendarSettingsPage({Key? key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      label: Config.isMP ? Translator.of(context).translate.settings : null,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.settings,
          text: Translator.of(context).translate.general,
          navigateTo: const CalendarGeneralSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.day,
          text: Translator.of(context).translate.dayCalendar,
          navigateTo: const DayCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.week,
          text: Translator.of(context).translate.weekCalendar,
          navigateTo: const WeekCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: Translator.of(context).translate.monthCalendar,
          navigateTo: const MonthCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.fullScreen,
          text: Translator.of(context).translate.activityView,
          navigateTo: const ActivityViewSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.newIcon,
          text: Translator.of(context).translate.addActivity,
          navigateTo: const AddActivitySettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.handiAlarmVibration,
          text: Translator.of(context).translate.alarmSettings,
          navigateTo: const AlarmSettingsPage(),
        ),
      ],
      icon: AbiliaIcons.month,
      title: Translator.of(context).translate.calendar,
    );
  }
}
