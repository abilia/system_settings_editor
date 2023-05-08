import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
              padding: EdgeInsets.symmetric(
                horizontal: layout.toolbar.horizontalPadding,
              ),
              child: Stack(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AddButton(),
                  ),
                  if (!display.onlyDayCalendar)
                    Align(
                      alignment: Alignment.center,
                      child: AbiliaTabs(
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
                              return context
                                  .read<ScrollPositionCubit>()
                                  .goToNow();
                            case 1:
                              if (display.week) {
                                return context
                                    .read<WeekCalendarCubit>()
                                    .goToCurrentWeek();
                              }
                              break;
                          }
                          final monthCalendarCubit = context
                              .read<MonthCalendarCubit>()
                            ..setCollapsed(true);
                          return monthCalendarCubit.goToCurrentMonth();
                        },
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.center,
                      child: TabControlledButton(
                        translate.day.capitalize(),
                        AbiliaIcons.day,
                        tabIndex: 0,
                      ),
                    ),
                  if (Config.isMPGO)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: MpGoMenuButton(),
                    )
                  else if (display.menu)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: MenuButton(),
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
