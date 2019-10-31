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
        data: weekDayTheme(context)[state.weekday].copyWith(buttonTheme: actionButtonTheme),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ActionButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () => _dayPickerBloc.add(PreviousDay()),
                ),
                Column(
                  children: [
                    Text(DateFormat('EEEE, d MMM', langCode).format(state)),
                    Text(DateFormat('yQQQQ', langCode).format(state)),
                  ],
                ),
                ActionButton(
                  child: Icon(Icons.arrow_forward),
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
                      child: Icon(Icons.refresh),
                      onPressed: () => _dayPickerBloc.add(CurrentDay()),
                      buttonThemeData: nowButtonTheme,
                    )
                  else
                    const SizedBox(width: 48),
                  ActionButton(
                    child: Icon(Icons.menu),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LogoutPage()),
                    ),
                    buttonThemeData: actionButtonTheme,
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
    return BlocBuilder<FilteredActivitiesBloc, FilteredActivitiesState>(
      builder: (context, state) {
        if (state is! FilteredActivitiesLoaded) {
          return CircularProgressIndicator();
        }
        final activities =
            (state as FilteredActivitiesLoaded).filteredActivities;
        return RefreshIndicator(
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) => ActivityTile(
              activity: activities[index],
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
