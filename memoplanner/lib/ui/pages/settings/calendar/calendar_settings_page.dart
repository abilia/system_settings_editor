import 'package:memoplanner/ui/all.dart';

class CalendarSettingsPage extends StatelessWidget {
  const CalendarSettingsPage({super.key});
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      label: Config.isMP ? Lt.of(context).settings : null,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.settings,
          text: Lt.of(context).general,
          navigateTo: const CalendarGeneralSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.day,
          text: Lt.of(context).dayCalendar,
          navigateTo: const DayCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.week,
          text: Lt.of(context).weekCalendar,
          navigateTo: const WeekCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.month,
          text: Lt.of(context).monthCalendar,
          navigateTo: const MonthCalendarSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.fullScreen,
          text: Lt.of(context).activityView,
          navigateTo: const ActivityViewSettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.newIcon,
          text: Lt.of(context).addActivity,
          navigateTo: const AddActivitySettingsPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.handiAlarmVibration,
          text: Lt.of(context).alarmSettings,
          navigateTo: const AlarmSettingsPage(),
        ),
      ],
      icon: AbiliaIcons.month,
      title: Lt.of(context).calendar,
    );
  }
}
