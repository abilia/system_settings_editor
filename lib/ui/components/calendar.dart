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
    final PageController controller =
        PageController(initialPage: DayPickerBloc.startIndex);
    return BlocProvider<ScrollPositionBloc>(
      create: (context) => _scrollPositionBloc,
      child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, activitiesState) =>
            BlocBuilder<DayPickerBloc, DayPickerState>(
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
                            ActivitiesOccasionState>(builder: (context, state) {
                          if (state is ActivitiesOccasionLoaded) {
                            return calendarViewState.currentView ==
                                    CalendarViewType.LIST
                                ? Agenda(state: state)
                                : TimePillar();
                          }
                          return Center(child: CircularProgressIndicator());
                        }, condition: (oldState, newState) {
                          return (oldState is ActivitiesOccasionLoaded &&
                                  newState is ActivitiesOccasionLoaded &&
                                  oldState.day == newState.day) ||
                              oldState.runtimeType != newState.runtimeType;
                        });
                      },
                    ),
                  ),
                  bottomNavigationBar:
                      buildBottomAppBar(calendarViewState.currentView, context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildBottomAppBar(CalendarViewType currentView, BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).bottomAppBarTheme.color),
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Stack(
          children: <Widget>[
            CalendarViewSwitchButton(currentView, key: TestKey.changeView),
            Align(
              alignment: Alignment(-0.42, 0.0),
              child: GoToNowButton(
                onPressed: () => _jumpToActivity(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ActionButton(
                child: Icon(
                  AbiliaIcons.plus,
                  size: 32,
                ),
                onPressed: () => {},
                themeData: addButtonTheme,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ActionButton(
                child: Icon(
                  AbiliaIcons.menu,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MenuPage()),
                ),
                themeData: menuButtonTheme,
              ),
            ),
          ],
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

class CalendarViewSwitchButton extends StatelessWidget {
  const CalendarViewSwitchButton(this.currentView, {Key key}) : super(key: key);
  final CalendarViewType currentView;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: menuButtonTheme,
      child: SizedBox(
        width: 72,
        height: 48,
        child: FlatButton(
          color: menuButtonTheme.buttonColor,
          highlightColor: menuButtonTheme.highlightColor,
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          textColor: menuButtonTheme.textTheme.button.color,
          child: Row(
            children: <Widget>[
              Icon(
                currentView == CalendarViewType.LIST
                    ? AbiliaIcons.list_order
                    : AbiliaIcons.timeline,
                size: 32,
              ),
              Icon(
                AbiliaIcons.navigation_down,
                size: 32,
              ),
            ],
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (newContext) => ChangeCalendarViewDialog(
                outerContext: context,
                currentViewType: currentView,
              ),
            );
          },
        ),
      ),
    );
  }
}
