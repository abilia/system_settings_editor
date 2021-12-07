import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarBottomBar extends StatelessWidget {
  static final barHeigt = layout.toolbar.heigth;
  const CalendarBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) =>
          BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, dayState) => BottomAppBar(
          child: Container(
            height: barHeigt,
            padding: EdgeInsets.only(
              left: layout.toolbar.horizontalPadding,
              right: layout.toolbar.horizontalPadding,
              bottom: layout.toolbar.bottomPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (settingsState.displayNewActivity)
                  AddActivityButton(day: dayState.day)
                else
                  SizedBox(width: layout.actionButton.size),
                if (!settingsState.displayOnlyDayCalendar)
                  AbiliaTabBar(
                    tabs: <Widget>[
                      TabItem(
                        translate.day.capitalize(),
                        AbiliaIcons.day,
                      ),
                      if (settingsState.displayWeekCalendar)
                        TabItem(
                          translate.week.capitalize(),
                          AbiliaIcons.week,
                        ),
                      if (settingsState.displayMonthCalendar)
                        TabItem(
                          translate.month,
                          AbiliaIcons.month,
                        ),
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
                  const MenuButton()
                else
                  SizedBox(width: layout.actionButton.size),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
