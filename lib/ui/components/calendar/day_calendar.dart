import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0.s, vertical: 28.0.s),
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
                onPressed: () => dayPickerBloc.add(PreviousDay()),
                child: Icon(AbiliaIcons.return_to_previous_page),
              ),
              rightAction: ActionButton(
                onPressed: () => dayPickerBloc.add(NextDay()),
                child: Icon(AbiliaIcons.go_to_next_page),
              ),
            )
          : DayAppBar(day: pickedDay);
}

class Calendars extends StatelessWidget {
  const Calendars({
    Key key,
    @required this.calendarViewState,
    @required this.memoplannerSettingsState,
  }) : super(key: key);

  final CalendarViewState calendarViewState;
  final MemoplannerSettingsState memoplannerSettingsState;

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: DayPickerBloc.startIndex);
    return BlocListener<DayPickerBloc, DayPickerState>(
      listener: (context, state) {
        controller.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            itemBuilder: (context, index) {
              return BlocBuilder<ActivitiesOccasionBloc,
                  ActivitiesOccasionState>(
                buildWhen: (oldState, newState) {
                  return (oldState is ActivitiesOccasionLoaded &&
                          newState is ActivitiesOccasionLoaded &&
                          oldState.day == newState.day) ||
                      oldState.runtimeType != newState.runtimeType;
                },
                builder: (context, activityState) {
                  if (activityState is ActivitiesOccasionLoaded) {
                    final fullDayActivities = activityState.fullDayActivities;
                    return Column(
                      children: <Widget>[
                        if (fullDayActivities.isNotEmpty)
                          FullDayContainer(
                            fullDayActivities: fullDayActivities,
                            day: activityState.day,
                          ),
                        Expanded(
                          child: Stack(
                            children: [
                              if (calendarViewState.currentDayCalendarType ==
                                  DayCalendarType.LIST)
                                Agenda(
                                  activityState: activityState,
                                  calendarViewState: calendarViewState,
                                  memoplannerSettingsState:
                                      memoplannerSettingsState,
                                )
                              else
                                BlocBuilder<TimepillarBloc, TimepillarState>(
                                  builder: (context, state) {
                                    return TimePillarCalendar(
                                      key: ValueKey(state.timepillarInterval),
                                      activityState: activityState,
                                      calendarViewState: calendarViewState,
                                      memoplannerSettingsState:
                                          memoplannerSettingsState,
                                      timepillarInterval:
                                          state.timepillarInterval,
                                    );
                                  },
                                ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0.s),
                                  child: EyeButton(
                                    currentDayCalendarType: calendarViewState
                                        .currentDayCalendarType,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 32.0.s),
                                  child: GoToNowButton(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
