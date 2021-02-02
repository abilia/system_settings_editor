import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/eye_button_settings.dart';
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
            builder: (context, memoSettingsState) => AnimatedTheme(
              key: TestKey.animatedTheme,
              data: weekdayTheme(
                      dayColor: memoSettingsState.calendarDayColor,
                      languageCode:
                          Localizations.localeOf(context).languageCode,
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
                  currentView: calendarViewState.currentView,
                  day: pickedDay.day,
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
  final barHeigt = 64.0;

  const CalendarBottomBar({
    Key key,
    @required this.currentView,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: bottomNavigationBarTheme,
      child: BottomAppBar(
        child: Container(
          height: barHeigt,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: EyeButton(currentCalendarType: currentView),
              ),
              Positioned(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GoToNowButton(),
                      const SizedBox(width: 14.0),
                      AddActivityButton(day: day),
                      const SizedBox(width: 14.0 + ActionButton.size),
                    ],
                  ),
                ),
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

class EyeButton extends StatelessWidget {
  const EyeButton({
    Key key,
    @required this.currentCalendarType,
  }) : super(key: key);

  final CalendarType currentCalendarType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => ActionButton(
        child: Icon(AbiliaIcons.show),
        onPressed: () async {
          final settings = await showViewDialog<EyeButtonSettings>(
            context: context,
            builder: (context) => EyeButtonDialog(
              currentCalendarType: currentCalendarType,
              currentDotsInTimepillar: state.dotsInTimepillar,
            ),
          );
          if (settings != null) {
            if (currentCalendarType != settings.calendarType) {
              await BlocProvider.of<CalendarViewBloc>(context)
                  .add(CalendarViewChanged(settings.calendarType));
            }
            if (state.dotsInTimepillar != settings.dotsInTimepillar) {
              await BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(settings.dotsInTimepillar));
            }
          }
        },
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
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: MenuPage(),
                  ),
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
