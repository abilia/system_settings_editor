import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarBottomBar extends StatelessWidget {
  const CalendarBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) {
        final tabItems = [
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
        ];

        return BottomAppBar(
          child: Container(
            height: layout.toolbar.height,
            padding: EdgeInsets.only(
              left: layout.toolbar.horizontalPadding,
              right: layout.toolbar.horizontalPadding,
              bottom: layout.toolbar.bottomPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const AddButton(),
                if (!settingsState.displayOnlyDayCalendar)
                  AbiliaTabs(
                    tabs: tabItems,
                    onTabTap: (index) {
                      context.read<DayPickerBloc>().add(CurrentDay());
                      switch (index) {
                        case 0:
                          return;
                        case 1:
                          if (settingsState.displayWeekCalendar) {
                            return context
                                .read<WeekCalendarCubit>()
                                .goToCurrentWeek();
                          }
                          break;
                      }
                      return context
                          .read<MonthCalendarCubit>()
                          .goToCurrentMonth();
                    },
                  )
                else
                  TabControlledButton(
                    translate.day.capitalize(),
                    AbiliaIcons.day,
                    tabIndex: 0,
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: AddButton.width(
                            settingsState.displayNewActivity,
                            settingsState.displayNewTimer,
                          ) -
                          (settingsState.displayMenu
                              ? layout.actionButton.size
                              : 0),
                    ),
                    if (settingsState.displayMenu)
                      MenuButton(tabIndex: tabItems.length),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
