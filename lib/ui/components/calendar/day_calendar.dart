// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayCalendar extends StatelessWidget {
  const DayCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionBloc>(
      create: (context) => ScrollPositionBloc(
        dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
        clockBloc: context.read<ClockBloc>(),
        timepillarBloc: context.read<TimepillarBloc>(),
      ),
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (old, fresh) =>
            old.settingsInaccessible != fresh.settingsInaccessible ||
            old.showCategories != fresh.showCategories ||
            old.displayDayCalendarAppBar != fresh.displayDayCalendarAppBar ||
            old.displayEyeButton != fresh.displayEyeButton,
        builder: (context, settingState) => Scaffold(
          appBar: settingState.displayDayCalendarAppBar
              ? DayCalendarAppBar()
              : null,
          body: BlocBuilder<PermissionBloc, PermissionState>(
            buildWhen: (old, fresh) =>
                old.notificationDenied != fresh.notificationDenied,
            builder: (context, state) => Stack(
              children: [
                const Calendars(),
                if (settingState.displayEyeButton)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: const EyeButton(),
                  ),
                if (state.notificationDenied)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 76.0.s,
                        right: 16.0.s,
                        bottom: 28.0.s,
                      ),
                      child: ErrorMessage(
                        text: Text(
                          Translator.of(context)
                              .translate
                              .notificationsWarningText,
                        ),
                      ),
                    ),
                  ),
                if (settingState.settingsInaccessible)
                  HiddenSetting(settingState.showCategories),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Calendars extends StatefulWidget {
  const Calendars({Key key}) : super(key: key);

  @override
  _CalendarsState createState() => _CalendarsState();
}

class _CalendarsState extends State<Calendars> with WidgetsBindingObserver {
  PageController pageController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController(
      initialPage: context.read<DayPickerBloc>().state.index,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<ScrollPositionBloc>().add(GoToNow());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DayPickerBloc, DayPickerState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
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
                if (activityState.day.dayIndex != index) return Container();
                final fullDayActivities = activityState.fullDayActivities;
                return Column(
                  children: <Widget>[
                    if (fullDayActivities.isNotEmpty)
                      FullDayContainer(
                        fullDayActivities: fullDayActivities,
                        day: activityState.day,
                      ),
                    Expanded(
                      child: BlocBuilder<MemoplannerSettingBloc,
                          MemoplannerSettingsState>(
                        buildWhen: (previous, current) =>
                            previous.dayCalendarType != current.dayCalendarType,
                        builder: (context, memoState) => Stack(
                          children: [
                            if (memoState.dayCalendarType ==
                                DayCalendarType.list)
                              Agenda(
                                activityState: activityState,
                              )
                            else
                              TimepillarCalendar(
                                activityState: activityState,
                              ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 32.0.s),
                                child: GoToNowButton(),
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
