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
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _scrollPositionBloc = ScrollPositionBloc();
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
      context
        ..bloc<ClockBloc>().add(DateTime.now().onlyMinutes())
        ..bloc<ActivitiesBloc>().add(LoadActivities())
        ..bloc<SortableBloc>().add(LoadSortables())
        ..bloc<GenericBloc>().add(LoadGenerics())
        ..bloc<LicenseBloc>().add(ReloadLicenses())
        ..bloc<PermissionBloc>().checkAll();
      _jumpToActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: DayPickerBloc.startIndex);
    return BlocProvider<ScrollPositionBloc>.value(
      value: _scrollPositionBloc,
      child: BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, pickedDay) =>
            BlocBuilder<CalendarViewBloc, CalendarViewState>(
          builder: (context, calendarViewState) {
            return BlocBuilder<MemoplannerSettingBloc,
                    MemoplannerSettingsState>(
                builder: (context, memoSettingsState) {
              return AnimatedTheme(
                key: TestKey.animatedTheme,
                data: weekDayThemes[memoSettingsState.calendarDayColor]
                    [pickedDay.day.weekday],
                child: Scaffold(
                  appBar: buildAppBar(
                    pickedDay.day,
                    memoSettingsState.dayCaptionShowDayButtons,
                  ),
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
                                  if (calendarViewState.currentView ==
                                      CalendarViewType.LIST)
                                    Expanded(
                                      child: Agenda(
                                        state: state,
                                        calendarViewState: calendarViewState,
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: TimePillarCalendar(
                                        state: state,
                                        now: context.bloc<ClockBloc>().state,
                                        calendarViewState: calendarViewState,
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
                  ),
                  bottomNavigationBar: CalendarBottomBar(
                    currentView: calendarViewState.currentView,
                    day: pickedDay.day,
                    goToNow: _jumpToActivity,
                  ),
                ),
              );
            });
          },
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
                onPressed: () => _dayPickerBloc.add(PreviousDay()),
              ),
              rightAction: ActionButton(
                child: Icon(
                  AbiliaIcons.go_to_next_page,
                  size: defaultIconSize,
                ),
                onPressed: () => _dayPickerBloc.add(NextDay()),
              ))
          : DayAppBar(day: pickedDay);

  void _jumpToActivity() {
    final scrollState = _scrollPositionBloc.state;
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
                              clockBloc: BlocProvider.of<ClockBloc>(context),
                              memoplannerSettingBloc:
                                  BlocProvider.of<MemoplannerSettingBloc>(
                                      context),
                              day: day,
                            ),
                            child: EditActivityPage(
                              day: day,
                              title:
                                  Translator.of(context).translate.newActivity,
                            ),
                          );
                        },
                        settings: RouteSettings(
                            name: 'EditActivityPage new activity'),
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
                    MaterialPageRoute(
                      builder: (context) => MenuPage(),
                      settings: RouteSettings(name: 'MenuPage'),
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
}
