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
                        condition: (oldState, newState) {
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
                bottomNavigationBar: buildBottomAppBar(
                  calendarViewState.currentView,
                  context,
                  pickedDay.day,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBottomAppBar(
      CalendarViewType currentView, BuildContext context, DateTime day) {
    return BottomAppBar(
      child: Container(
        height: 64,
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
                key: TestKey.addActivity,
                themeData: addButtonTheme,
                child: Icon(
                  AbiliaIcons.plus,
                  size: 32,
                ),
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
                            title: Translator.of(context).translate.newActivity,
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
      ),
    );
  }
}
