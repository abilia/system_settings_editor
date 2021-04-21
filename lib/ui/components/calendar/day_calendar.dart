import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendar extends StatelessWidget {
  const DayCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (old, fresh) =>
          old.settingsInaccessible != fresh.settingsInaccessible ||
          old.showCategories != fresh.showCategories ||
          old.displayDayCalendarAppBar != fresh.displayDayCalendarAppBar,
      builder: (context, settingState) => Scaffold(
        appBar:
            settingState.displayDayCalendarAppBar ? DayCalendarAppBar() : null,
        body: BlocBuilder<PermissionBloc, PermissionState>(
          buildWhen: (old, fresh) =>
              old.notificationDenied != fresh.notificationDenied,
          builder: (context, state) => Stack(
            children: [
              const Calendars(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(16.0.s),
                  child: const EyeButton(),
                ),
              ),
              if (state.notificationDenied)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 76.0.s, right: 16.0.s, bottom: 28.0.s),
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
    );
  }
}

class Calendars extends StatelessWidget {
  const Calendars({Key key}) : super(key: key);

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
                    Expanded(
                      child: BlocBuilder<CalendarViewBloc, CalendarViewState>(
                        builder: (context, calendarViewState) => Stack(
                          children: [
                            if (calendarViewState.currentDayCalendarType ==
                                DayCalendarType.LIST)
                              Agenda(
                                activityState: activityState,
                                calendarViewState: calendarViewState,
                              )
                            else
                              TimepillarCalendar(
                                activityState: activityState,
                                calendarViewState: calendarViewState,
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
