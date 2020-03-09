import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;

  const ActivityPage({Key key, @required this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = weekDayTheme[occasion.day.weekday];
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activity = state.newActivityFromLoadedOrGiven(occasion.activity);
        return Theme(
          data: themeData,
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(68),
                child: DayAppBar(
                  day: occasion.day,
                  leftAction: ActionButton(
                    key: TestKey.activityBackButton,
                    child: Icon(
                      AbiliaIcons.navigation_previous,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ActivityInfo(
                activity: activity,
                day: occasion.day,
              ),
            ),
            bottomNavigationBar: buildBottomAppBar(activity, context),
          ),
        );
      },
    );
  }

  BottomAppBar buildBottomAppBar(Activity activity, BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ActionButton(
                key: TestKey.editAlarm,
                themeData: menuButtonTheme,
                child: Icon(
                  activity.alarm.iconData(),
                  size: 32,
                ),
                onPressed: () async {
                  final alarm = activity.alarm;
                  final result = await showViewDialog<Alarm>(
                    context: context,
                    builder: (context) => SelectAlarmTypeDialog(
                      alarm: alarm.type,
                    ),
                  );
                  if (result != null) {
                    final changedActivity =
                        activity.copyWith(alarm: alarm.copyWith(type: result));
                    BlocProvider.of<ActivitiesBloc>(context)
                        .add(UpdateActivity(changedActivity));
                  }
                },
              ),
              ActionButton(
                key: TestKey.editReminder,
                themeData: menuButtonTheme,
                child: Icon(
                  AbiliaIcons.handi_reminder,
                  size: 32,
                ),
                onPressed: () {
                  final addAcitivityBloc = AddActivityBloc(
                    activity: activity,
                    activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                    newActivity: false,
                  );
                  showViewDialog<bool>(
                    context: context,
                    builder: (context) => BlocProvider<AddActivityBloc>.value(
                      value: addAcitivityBloc,
                      child: SelectReminderDialog(activity: activity),
                    ),
                  );
                },
              ),
              ActionButton(
                themeData: menuButtonTheme,
                child: Icon(
                  AbiliaIcons.edit,
                  size: 32,
                ),
                onPressed: () async {
                  final now = BlocProvider.of<ClockBloc>(context).state;
                  final sortableBloc = BlocProvider.of<SortableBloc>(context);
                  final activitiesBloc =
                      BlocProvider.of<ActivitiesBloc>(context);
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider<AddActivityBloc>(
                              create: (context) => AddActivityBloc(
                                activitiesBloc: activitiesBloc,
                                activity: activity,
                                newActivity: false,
                              ),
                            ),
                            BlocProvider<SortableBloc>.value(
                              value: sortableBloc,
                            ),
                          ],
                          child: NewActivityPage(today: now.onlyDays()),
                        );
                      },
                    ),
                  );
                },
              ),
              ActionButton(
                themeData: menuButtonTheme,
                child: Icon(
                  AbiliaIcons.delete_all_clear,
                  size: 32,
                ),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
