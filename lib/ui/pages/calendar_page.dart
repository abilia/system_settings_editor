import 'dart:math';

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
      _jumpToActivity();
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
            builder: (context, memoSettingsState) => AnimatedTheme(
              key: TestKey.animatedTheme,
              data: weekDayThemes[memoSettingsState.calendarDayColor]
                  [pickedDay.day.weekday],
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
                  currentView: calendarViewState.currentView,
                  day: pickedDay.day,
                  goToNow: _jumpToActivity,
                ),
              ),
            ),
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
                if (!activityState.isToday) {
                  BlocProvider.of<ScrollPositionBloc>(context)
                      .add(WrongDaySelected());
                }
                final fullDayActivities = activityState.fullDayActivities;
                return Column(
                  children: <Widget>[
                    if (fullDayActivities.isNotEmpty)
                      FullDayContainer(
                        fullDayActivities: fullDayActivities,
                        day: activityState.day,
                      ),
                    if (calendarViewState.currentView == CalendarType.LIST)
                      Expanded(
                        child: Agenda(
                          activityState: activityState,
                          calendarViewState: calendarViewState,
                          memoplannerSettingsState: memoplannerSettingsState,
                        ),
                      )
                    else
                      Expanded(
                        child: BlocBuilder<TimepillarBloc, TimepillarState>(
                            builder: (context, state) {
                          if (state is ActivitiesNotLoaded) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return TimePillarCalendar(
                            key: ValueKey(state.timepillarInterval),
                            activityState: activityState,
                            calendarViewState: calendarViewState,
                            memoplannerSettingsState: memoplannerSettingsState,
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
    );
  }
}

class CalendarBottomBar extends StatelessWidget {
  final CalendarType currentView;
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
                    currentView == CalendarType.LIST
                        ? AbiliaIcons.list_order
                        : AbiliaIcons.timeline,
                  ),
                  Icon(AbiliaIcons.navigation_down),
                ]),
                onPressed: () async {
                  final result = await showViewDialog<CalendarType>(
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
                child: AddActivityButton(day: day),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: MenuButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        return Stack(
          overflow: Overflow.visible,
          children: [
            ActionButton(
              child: const Icon(AbiliaIcons.menu),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MenuPage(),
                  settings: RouteSettings(name: 'MenuPage'),
                ),
              ),
            ),
            if (state.importantPermissionMissing)
              const Positioned(
                top: -3,
                right: -3,
                child: OrangeDot(),
              ),
          ],
        );
      },
    );
  }
}

class CreateActivityDialogResponse {
  final BasicActivityDataItem basicActivityData;

  CreateActivityDialogResponse({this.basicActivityData});
}

class CreateActivityDialog extends StatefulWidget {
  const CreateActivityDialog({Key key}) : super(key: key);

  @override
  _CreateActivityDialogState createState() => _CreateActivityDialogState(false);
}

class _CreateActivityDialogState extends State<CreateActivityDialog>
    with SingleTickerProviderStateMixin {
  bool pickBasicActivityView;

  _CreateActivityDialogState(this.pickBasicActivityView);
  @override
  Widget build(BuildContext context) {
    return pickBasicActivityView
        ? buildPickBasicActivity()
        : buildSelectNewOrBase();
  }

  Widget buildPickBasicActivity() {
    return BlocBuilder<SortableArchiveBloc<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (innerContext, sortableArchiveState) => ViewDialog(
        verticalPadding: 0,
        backButton: sortableArchiveState.currentFolderId == null
            ? null
            : SortableLibraryBackButton<BasicActivityData>(),
        heading: getSortableArchiveHeading(sortableArchiveState),
        child: SortableLibrary<BasicActivityData>(
          (Sortable<BasicActivityData> s) => BasicActivityLibraryItem(
            basicActivityData: s.data,
          ),
        ),
      ),
    );
  }

  Text getSortableArchiveHeading(SortableArchiveState state) {
    final folderName = state.allById[state.currentFolderId]?.data?.title() ??
        Translator.of(context).translate.basicActivities;
    return Text(folderName, style: abiliaTheme.textTheme.headline6);
  }

  Widget buildSelectNewOrBase() {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      heading: Text(
        translate.createActivity,
        style: abiliaTextTheme.headline6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PickField(
            key: TestKey.newActivityButton,
            leading: Icon(
              AbiliaIcons.new_icon,
              size: smallIconSize,
            ),
            text: Text(
              translate.newActivity,
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async => await Navigator.of(context)
                .maybePop(CreateActivityDialogResponse()),
          ),
          SizedBox(height: 8.0),
          PickField(
            key: TestKey.selectBasicActivityButton,
            leading: Icon(AbiliaIcons.day, size: smallIconSize),
            text: Text(
              translate.fromBasicActivity,
              style: abiliaTheme.textTheme.bodyText1,
            ),
            onTap: () async => setState(
              () {
                pickBasicActivityView = true;
              },
            ),
          ),
        ],
      ),
    );
  }
}
