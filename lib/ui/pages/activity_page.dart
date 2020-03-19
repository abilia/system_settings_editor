import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;
  final ThemeData dayThemeData;

  ActivityPage({Key key, @required this.occasion})
      : dayThemeData = weekDayTheme[occasion.day.weekday],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activity = state.newActivityFromLoadedOrGiven(occasion.activity);
        final day = occasion.day;
        return AnimatedTheme(
          data: dayThemeData,
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(68),
                child: AnimatedSwitcher(
                  duration: 200.milliseconds(),
                  child: DayAppBar(
                    day: day,
                    leftAction: ActionButton(
                      key: TestKey.activityBackButton,
                      child: Icon(
                        AbiliaIcons.navigation_previous,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ActivityInfo(
                  activity: activity,
                  day: day,
                ),
              ),
              bottomNavigationBar: buildBottomAppBar(activity, context)),
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
                  final result = await showViewDialog<AlarmType>(
                    context: context,
                    builder: (context) => SelectAlarmDialog(
                      alarm: alarm,
                    ),
                  );
                  if (result != null) {
                    final changedActivity = activity.copyWith(alarm: result);
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
                  final editActivityBloc = EditActivityBloc(
                    activity: activity,
                    activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                    newActivity: false,
                  );
                  showViewDialog<bool>(
                    context: context,
                    builder: (context) => BlocProvider<EditActivityBloc>.value(
                      value: editActivityBloc,
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
                  final userFileBloc = BlocProvider.of<UserFileBloc>(context);
                  final activitiesBloc =
                      BlocProvider.of<ActivitiesBloc>(context);
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider<EditActivityBloc>(
                              create: (context) => EditActivityBloc(
                                activitiesBloc: activitiesBloc,
                                activity: activity,
                                newActivity: false,
                              ),
                            ),
                            BlocProvider<SortableBloc>.value(
                              value: sortableBloc,
                            ),
                            BlocProvider<UserFileBloc>.value(
                              value: userFileBloc,
                            ),
                          ],
                          child: EditActivityPage(
                            today: now.onlyDays(),
                            title:
                                Translator.of(context).translate.editActivity,
                          ),
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
                onPressed: () async {
                  final shouldDelete = await showViewDialog<bool>(
                    context: context,
                    builder: (context) =>
                        DeleteActivityDialog(activityOccasion: occasion),
                  );
                  if (shouldDelete == true) {
                    BlocProvider.of<ActivitiesBloc>(context)
                        .add(DeleteActivity(activity));
                    await Navigator.of(context).maybePop();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
