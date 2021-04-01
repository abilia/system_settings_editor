import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendar extends StatelessWidget {
  final CalendarViewState calendarViewState;
  const DayCalendar({
    Key key,
    @required this.calendarViewState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DayCalendarAppBar(),
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Stack(
          children: [
            Calendars(calendarViewState: calendarViewState),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16.0.s),
                child: EyeButton(
                  currentDayCalendarType:
                      calendarViewState.currentDayCalendarType,
                ),
              ),
            ),
            if (state.notificationDenied)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 76.0.s, right: 16.0, bottom: 28.0.s),
                  child: ErrorMessage(
                    text: Text(
                      Translator.of(context).translate.notificationsWarningText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Calendars extends StatelessWidget {
  const Calendars({
    Key key,
    @required this.calendarViewState,
  }) : super(key: key);

  final CalendarViewState calendarViewState;

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: DayPickerBloc.startIndex);
    return BlocListener<DayPickerBloc, DayPickerState>(
      listener: (context, state) {
        controller.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        itemBuilder: (context, index) {
          return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
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
                            )
                          else
                            BlocBuilder<TimepillarBloc, TimepillarState>(
                              builder: (context, state) => BlocBuilder<
                                  MemoplannerSettingBloc,
                                  MemoplannerSettingsState>(
                                builder: (context, memoplannerSettingsState) =>
                                    TimePillarCalendar(
                                  key: ValueKey(state.timepillarInterval),
                                  activityState: activityState,
                                  calendarViewState: calendarViewState,
                                  memoplannerSettingsState:
                                      memoplannerSettingsState,
                                  timepillarState: state,
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
    );
  }
}
