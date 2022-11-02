import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarBottomBar extends StatelessWidget {
  const CalendarBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final display = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.functions.display);
    return DefaultTabControllerBuilder(
      builder: (context, tabController) {
        final translate = Translator.of(context).translate;
        final height = display.photoAlbumTabIndex == tabController?.index
            ? 0.0
            : layout.toolbar.height;
        final tabItems = [
          TabItem(
            translate.day.capitalize(),
            AbiliaIcons.day,
          ),
          TabItem(
            translate.week.capitalize(),
            AbiliaIcons.week,
          ),
          TabItem(
            translate.month,
            AbiliaIcons.month,
          ),
        ];

        return BottomAppBar(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Container(
              height: height,
              padding: EdgeInsets.only(
                left: layout.toolbar.horizontalPadding,
                right: layout.toolbar.horizontalPadding,
                bottom: layout.toolbar.bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const AddButton(),
                  if (!display.onlyDayCalendar)
                    AbiliaTabs(
                      tabs: tabItems,
                      useOffset: false,
                      collapsedCondition: (i) {
                        switch (i) {
                          case 1:
                            return !display.week;
                          case 2:
                            return !display.month;
                          default:
                            return false;
                        }
                      },
                      onTabTap: (index) async {
                        context.read<DayPickerBloc>().add(const CurrentDay());
                        switch (index) {
                          case 0:
                            return;
                          case 1:
                            if (display.week) {
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
                        width: AddButton.width(display) -
                            (display.menu ? layout.actionButton.size : 0),
                      ),
                      if (Config.isMPGO)
                        const MpGoMenuButton()
                      else if (display.menu)
                        const MenuButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
