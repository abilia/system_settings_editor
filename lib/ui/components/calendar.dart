import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';
import 'package:seagull/ui/components/calendar/day_app_bar.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with WidgetsBindingObserver {
  DayPickerBloc _dayPickerBloc;
  ActivitiesBloc _activitiesBloc;
  ScrollPositionBloc _scrollPositionBloc;
  ClockBloc _clockBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _clockBloc = BlocProvider.of<ClockBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc();
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
      _jumpToActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionBloc>(
      create: (context) => _scrollPositionBloc,
      child: BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => BlocBuilder<DayPickerBloc, DateTime>(
          builder: (context, pickedDay) {
            return BlocBuilder<CalendarViewBloc, CalendarViewState>(
              builder: (context, calendarViewState) {
                final themeData = weekDayTheme[pickedDay.weekday];
                return AnimatedTheme(
                  data: themeData,
                  child: Scaffold(
                    appBar: buildAppBar(pickedDay),
                    body: calendarViewState.currentView == CalendarViewType.LIST
                        ? Agenda()
                        : TimePillar(),
                    bottomNavigationBar: BottomAppBar(
                      child: SizedBox(
                        height: 64,
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                    child: ActionButton(
                                      key: Key('changeView'),
                                      width: 65,
                                      child: Row(
                                        children: <Widget>[
                                          calendarViewState.currentView ==
                                                  CalendarViewType.LIST
                                              ? Icon(AbiliaIcons.phone_log)
                                              : Icon(AbiliaIcons.timeline),
                                          Icon(AbiliaIcons.navigation_down)
                                        ],
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (newContext) =>
                                                ChangeCalendarViewDialog(
                                                  outerContext: context,
                                                  currentViewType:
                                                      calendarViewState
                                                          .currentView,
                                                ));
                                      },
                                      themeData: menuButtonTheme,
                                    ),
                                  ),
                                  GoToNowButton(
                                    onPressed: () => _jumpToActivity(),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ActionButton(
                                child: Icon(
                                  AbiliaIcons.menu,
                                  size: 32,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => MenuPage()),
                                ),
                                themeData: menuButtonTheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSize buildAppBar(DateTime pickedDay) {
    final leftAction = ActionButton(
      child: Icon(
        AbiliaIcons.return_to_previous_page,
        size: 32,
      ),
      onPressed: () => _dayPickerBloc.add(PreviousDay()),
    );
    final rightAction = ActionButton(
      child: Icon(
        AbiliaIcons.go_to_next_page,
        size: 32,
      ),
      onPressed: () => _dayPickerBloc.add(NextDay()),
    );
    return PreferredSize(
      preferredSize: Size.fromHeight(68),
      child: DayAppBar(
        day: pickedDay,
        leftAction: leftAction,
        rightAction: rightAction,
      ),
    );
  }

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
