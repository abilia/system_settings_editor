import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class Calender extends StatefulWidget {
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DayPickerBloc _dayPickerBloc;
  ActivitiesBloc _activitiesBloc;
  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    return BlocBuilder<DayPickerBloc, DateTime>(
      builder: (context, state) => Theme(
        data: weekDayTheme(context)[state.weekday],
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ActionButton(
                  child: Icon(AbiliaIcons.return_to_previous_page),
                  onPressed: () => _dayPickerBloc.add(PreviousDay()),
                ),
                Column(
                  children: [
                    Text(DateFormat('EEEE, d MMM', langCode).format(state)),
                    Text(DateFormat('yQQQQ', langCode).format(state)),
                  ],
                ),
                ActionButton(
                  child: Icon(AbiliaIcons.go_to_next_page),
                  onPressed: () => _dayPickerBloc.add(NextDay()),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: page(),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (!isAtTheSameDayAsNow(state))
                    ActionButton(
                      child: Icon(AbiliaIcons.reset),
                      onPressed: () => _dayPickerBloc.add(CurrentDay()),
                      themeData: nowButtonTheme(context),
                    )
                  else
                    const SizedBox(width: 48),
                  ActionButton(
                    child: Icon(AbiliaIcons.menu),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LogoutPage()),
                    ),
                    themeData: menuButtonTheme(context),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  isAtTheSameDayAsNow(DateTime otherTime) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).isAtSameMomentAs(
        DateTime(otherTime.year, otherTime.month, otherTime.day));
  }

  Widget page() {
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
      builder: (context, state) {
        if (state is! ActivitiesOccasionLoaded) {
          return Center(child: CircularProgressIndicator());
        }
        final activities =
            (state as ActivitiesOccasionLoaded).activityStates;
        return RefreshIndicator(
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Scrollbar(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: activities.length,
                itemBuilder: (context, index) => ActivityCard(
                  activityOccasion: activities[index],
                ),
              ),
            ),
          ),
          onRefresh: refresh,
        );
      },
    );
  }

  Future<void> refresh() {
    _activitiesBloc.add(LoadActivities());
    return _activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
  }
}
