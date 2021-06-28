// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarBottomBar extends StatelessWidget {
  static final barHeigt = 64.0.s;
  const CalendarBottomBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) =>
          BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, dayState) => BottomAppBar(
          child: Container(
            height: barHeigt,
            padding: EdgeInsets.symmetric(horizontal: 16.0.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (settingsState.displayNewActivity)
                  AddActivityButton(day: dayState.day)
                else
                  SizedBox(width: actionButtonMinSize),
                if (!settingsState.displayOnlyDayCalendar)
                  AbiliaTabBar(
                    tabs: <Widget>[
                      Icon(AbiliaIcons.day),
                      if (settingsState.displayWeekCalendar)
                        Icon(AbiliaIcons.week),
                      if (settingsState.displayMonthCalendar)
                        Icon(AbiliaIcons.month),
                    ],
                    onTabTap: (index) {
                      context.read<DayPickerBloc>().add(CurrentDay());
                      switch (index) {
                        case 0:
                          return;
                        case 1:
                          if (settingsState.displayWeekCalendar) {
                            return context
                                .read<WeekCalendarBloc>()
                                .add(GoToCurrentWeek());
                          }
                          break;
                      }
                      return context
                          .read<MonthCalendarBloc>()
                          .add(GoToCurrentMonth());
                    },
                  )
                else
                  const Spacer(),
                if (settingsState.displayMenu)
                  MenuButton()
                else
                  SizedBox(width: actionButtonMinSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
