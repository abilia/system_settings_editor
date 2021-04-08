import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarBottomBar extends StatelessWidget {
  static final barHeigt = 64.0.s;
  final MemoplannerSettingsLoaded settingsState;
  const CalendarBottomBar(
    this.settingsState, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayPickerBloc, DayPickerState>(
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
    );
  }
}
