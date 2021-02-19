import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  DayPickerBloc _dayPickerBloc;
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc(
      dayPickerBloc: _dayPickerBloc,
      clockBloc: context.read<ClockBloc>(),
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _scrollPositionBloc.add(GoToNow());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionBloc>.value(
      value: _scrollPositionBloc,
      child: BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, pickedDay) =>
            BlocBuilder<CalendarViewBloc, CalendarViewState>(
          builder: (context, calendarViewState) =>
              BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, memoSettingsState) {
              if (calendarViewState.currentCalendarPeriod ==
                  CalendarPeriod.DAY) {
                return DayCalendar(
                  calendarViewState: calendarViewState,
                  dayPickerBloc: _dayPickerBloc,
                  memoSettingsState: memoSettingsState,
                  pickedDay: pickedDay,
                );
              } else if (calendarViewState.currentCalendarPeriod ==
                  CalendarPeriod.WEEK) {
                return WeekCalendar();
              } else {
                return MonthCalendar();
              }
            },
          ),
        ),
      ),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: CalendarBottomBar(
        day: DateTime.now(),
      ),
    );
  }
}

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: CalendarBottomBar(
        day: DateTime.now(),
      ),
    );
  }
}

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
        bottomNavigationBar: CalendarBottomBar(
          day: pickedDay.day,
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
                        if (calendarViewState.currentDayCalendarType ==
                            DayCalendarType.LIST)
                          Expanded(
                            child: Agenda(
                              activityState: activityState,
                              calendarViewState: calendarViewState,
                              memoplannerSettingsState:
                                  memoplannerSettingsState,
                            ),
                          )
                        else
                          Expanded(
                            child: BlocBuilder<TimepillarBloc, TimepillarState>(
                                builder: (context, state) {
                              return TimePillarCalendar(
                                key: ValueKey(state.timepillarInterval),
                                activityState: activityState,
                                calendarViewState: calendarViewState,
                                memoplannerSettingsState:
                                    memoplannerSettingsState,
                                timepillarInterval: state.timepillarInterval,
                              );
                            }),
                          ),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: GoToNowButton(),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: EyeButton(
                currentDayCalendarType:
                    calendarViewState.currentDayCalendarType,
              ),
            ),
          )
        ],
      ),
    );
  }
}
