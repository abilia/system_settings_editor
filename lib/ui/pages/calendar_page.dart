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
              return DefaultTabController(
                initialIndex: 0,
                length: 3,
                child: Scaffold(
                  body: TabBarView(children: [
                    DayCalendar(
                      calendarViewState: calendarViewState,
                      dayPickerBloc: _dayPickerBloc,
                      memoSettingsState: memoSettingsState,
                      pickedDay: pickedDay,
                    ),
                    WeekCalendar(),
                    MonthCalendar()
                  ]),
                  bottomNavigationBar: CalendarBottomBar(
                    day: pickedDay.day,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
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
                                  padding: const EdgeInsets.all(16.0),
                                  child: EyeButton(
                                    currentDayCalendarType: calendarViewState
                                        .currentDayCalendarType,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
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
