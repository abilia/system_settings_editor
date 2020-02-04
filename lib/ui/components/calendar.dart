import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';
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
    final PageController controller = PageController();
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
                                    key: TestKey.changeView,
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
                                              calendarViewState.currentView,
                                        ),
                                      );
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
          ),
        ),
      ),
    );
  }

  PreferredSize buildAppBar(DateTime pickedDay) {
    final langCode = Locale.cachedLocale.languageCode;
    return PreferredSize(
      preferredSize: Size.fromHeight(68),
      child: Builder(
        builder: (context) {
          final themeData = Theme.of(context);
          return AppBar(
            brightness: getThemeAppBarBrightness()[pickedDay.weekday],
            elevation: 0.0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ActionButton(
                      child: Icon(
                        AbiliaIcons.return_to_previous_page,
                        size: 32,
                      ),
                      onPressed: () => _dayPickerBloc.add(PreviousDay()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM', langCode).format(pickedDay),
                          style: themeData.textTheme.title,
                        ),
                        Text(
                          '${Translator.of(context).translate.week} ${pickedDay.getWeekNumber()}',
                          style: themeData.textTheme.subhead,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ActionButton(
                      child: Icon(
                        AbiliaIcons.go_to_next_page,
                        size: 32,
                      ),
                      onPressed: () => _dayPickerBloc.add(NextDay()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
