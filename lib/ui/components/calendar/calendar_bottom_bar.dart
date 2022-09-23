import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarBottomBar extends StatelessWidget {
  const CalendarBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) {
        final display = context.select(
          (MemoplannerSettingBloc bloc) =>
              bloc.state.settings.functions.display,
        );
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
              if (display.week)
                TabItem(
                  translate.week.capitalize(),
                  AbiliaIcons.week,
                ),
              if (display.month)
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
                          onTabTap: (index) async {
                            context
                                .read<DayPickerBloc>()
                                .add(const CurrentDay());
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
                            MenuButton(tabIndex: tabItems.length),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
