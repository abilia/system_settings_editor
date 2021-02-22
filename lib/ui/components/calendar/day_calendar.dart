import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendar extends StatelessWidget {
  final MemoplannerSettingsState memoSettingsState;
  final DayPickerState pickedDay;
  final DayPickerBloc dayPickerBloc;
  final CalendarViewState calendarViewState;
  const DayCalendar({
    Key key,
    @required this.memoSettingsState,
    @required this.pickedDay,
    @required this.dayPickerBloc,
    @required this.calendarViewState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      key: TestKey.animatedTheme,
      data: weekdayTheme(
              dayColor: memoSettingsState.calendarDayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: pickedDay.day.weekday)
          .theme,
      child: Scaffold(
        appBar: buildAppBar(
          pickedDay.day,
          memoSettingsState.dayCaptionShowDayButtons,
        ),
        body: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) => Stack(
            children: [
              Calendars(
                calendarViewState: calendarViewState,
                memoplannerSettingsState: memoSettingsState,
              ),
              if (state.notificationDenied)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 28.0),
                    child: ErrorMessage(
                      text: Text(
                        Translator.of(context)
                            .translate
                            .notificationsWarningText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(
    DateTime pickedDay,
    bool dayCaptionShowDayButtons,
  ) =>
      dayCaptionShowDayButtons
          ? DayAppBar(
              day: pickedDay,
              leftAction: ActionButton(
                child: Icon(
                  AbiliaIcons.return_to_previous_page,
                  size: defaultIconSize,
                ),
                onPressed: () => dayPickerBloc.add(PreviousDay()),
              ),
              rightAction: ActionButton(
                child: Icon(
                  AbiliaIcons.go_to_next_page,
                  size: defaultIconSize,
                ),
                onPressed: () => dayPickerBloc.add(NextDay()),
              ))
          : DayAppBar(day: pickedDay);
}
