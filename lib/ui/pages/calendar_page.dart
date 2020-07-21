import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  DayPickerBloc _dayPickerBloc;
  ActivitiesBloc _activitiesBloc;
  ScrollPositionBloc _scrollPositionBloc;
  SortableBloc _sortableBloc;
  ClockBloc _clockBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _clockBloc = BlocProvider.of<ClockBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc();
    _sortableBloc = BlocProvider.of<SortableBloc>(context);
    BlocProvider.of<UserFileBloc>(context).add(LoadUserFiles());
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
      _clockBloc.add(DateTime.now().onlyMinutes());
      _activitiesBloc.add(LoadActivities());
      _sortableBloc.add(LoadSortables());
      _jumpToActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: DayPickerBloc.startIndex);
    return BlocProvider<ScrollPositionBloc>(
      create: (context) => _scrollPositionBloc,
      child: BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, pickedDay) =>
            BlocBuilder<CalendarViewBloc, CalendarViewState>(
          builder: (context, calendarViewState) {
            return AnimatedTheme(
              data: weekDayTheme[pickedDay.day.weekday],
              child: Scaffold(
                appBar: buildAppBar(pickedDay.day),
                body: BlocListener<DayPickerBloc, DayPickerState>(
                  listener: (context, state) {
                    controller.animateToPage(state.index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOutQuad);
                  },
                  child: PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
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
                        builder: (context, state) {
                          if (state is ActivitiesOccasionLoaded) {
                            if (!state.isToday) {
                              BlocProvider.of<ScrollPositionBloc>(context)
                                  .add(WrongDaySelected());
                            }
                            final fullDayActivities = state.fullDayActivities;
                            return Column(
                              children: <Widget>[
                                if (fullDayActivities.isNotEmpty)
                                  FullDayContainer(
                                    fullDayActivities: fullDayActivities,
                                    day: state.day,
                                  ),
                                Expanded(
                                  child: calendarViewState.currentView ==
                                          CalendarViewType.LIST
                                      ? Agenda(
                                          state: state,
                                        )
                                      : TimePillarCalendar(
                                          state: state,
                                          now: _clockBloc.state,
                                          calendarViewState: calendarViewState,
                                        ),
                                )
                              ],
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  ),
                ),
                bottomNavigationBar: CalendarBottomBar(
                  currentView: calendarViewState.currentView,
                  day: pickedDay.day,
                  goToNow: _jumpToActivity,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildAppBar(DateTime pickedDay) => DayAppBar(
        day: pickedDay,
        leftAction: ActionButton(
          child: Icon(
            AbiliaIcons.return_to_previous_page,
            size: 32,
          ),
          onPressed: () => _dayPickerBloc.add(PreviousDay()),
        ),
        rightAction: ActionButton(
          child: Icon(
            AbiliaIcons.go_to_next_page,
            size: 32,
          ),
          onPressed: () => _dayPickerBloc.add(NextDay()),
        ),
      );

  void _jumpToActivity() async {
    final scrollState = await _scrollPositionBloc.first;
    if (scrollState is OutOfView) {
      final sc = scrollState.scrollController;
      sc.jumpTo(min(sc.initialScrollOffset, sc.position.maxScrollExtent));
    } else if (scrollState is WrongDay) {
      _dayPickerBloc.add(CurrentDay());
    }
  }
}

class CalendarBottomBar extends StatelessWidget {
  final CalendarViewType currentView;
  final DateTime day;
  final Function goToNow;
  final barHeigt = 64.0, calendarSwitchButtonWidth = 72.0;

  const CalendarBottomBar({
    Key key,
    @required this.currentView,
    @required this.day,
    @required this.goToNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: bottomNavigationBarTheme,
      child: BottomAppBar(
        child: Container(
          height: barHeigt,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Stack(
            children: <Widget>[
              ActionButton(
                key: TestKey.changeView,
                width: calendarSwitchButtonWidth,
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Row(children: <Widget>[
                  Icon(
                    currentView == CalendarViewType.LIST
                        ? AbiliaIcons.list_order
                        : AbiliaIcons.timeline,
                  ),
                  Icon(AbiliaIcons.navigation_down),
                ]),
                onPressed: () async {
                  final result = await showViewDialog<CalendarViewType>(
                    context: context,
                    builder: (context) => ChangeCalendarDialog(
                      currentViewType: currentView,
                    ),
                  );
                  if (result != null) {
                    BlocProvider.of<CalendarViewBloc>(context)
                        .add(CalendarViewChanged(result));
                  }
                },
              ),
              Positioned(
                left: calendarSwitchButtonWidth + 14.0,
                child: GoToNowButton(onPressed: goToNow),
              ),
              Align(
                alignment: Alignment.center,
                child: ActionButton(
                  key: TestKey.addActivity,
                  child: Icon(AbiliaIcons.plus),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return BlocProvider<EditActivityBloc>(
                            create: (_) => EditActivityBloc.newActivity(
                              activitiesBloc:
                                  BlocProvider.of<ActivitiesBloc>(context),
                              day: day,
                            ),
                            child: EditActivityPage(
                              day: day,
                              title:
                                  Translator.of(context).translate.newActivity,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ActionButton(
                  child: Icon(AbiliaIcons.menu),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
