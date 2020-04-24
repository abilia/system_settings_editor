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
              bottomNavigationBar: buildBottomAppBar(activity, day, context)),
        );
      },
    );
  }

  BottomAppBar buildBottomAppBar(
      Activity activity, DateTime day, BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (activity.fullDay)
                const SizedBox(width: 48)
              else
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
                      if (activity.isRecurring) {
                        final applyTo = await showViewDialog<ApplyTo>(
                          context: context,
                          builder: (context) => EditRecurrentDialog(),
                        );
                        if (applyTo == null) return;
                        BlocProvider.of<ActivitiesBloc>(context).add(
                          UpdateRecurringActivity(
                            changedActivity,
                            applyTo,
                            day,
                          ),
                        );
                      } else {
                        BlocProvider.of<ActivitiesBloc>(context)
                            .add(UpdateActivity(changedActivity));
                      }
                    }
                  },
                ),
              if (activity.fullDay)
                const SizedBox(width: 48)
              else
                ActionButton(
                  key: TestKey.editReminder,
                  themeData: menuButtonTheme,
                  child: Icon(
                    AbiliaIcons.handi_reminder,
                    size: 32,
                  ),
                  onPressed: () => showViewDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider<EditActivityBloc>.value(
                      value: EditActivityBloc(
                          activity: activity,
                          day: day,
                          activitiesBloc:
                              BlocProvider.of<ActivitiesBloc>(context)),
                      child: SelectReminderDialog(
                        activity: activity,
                        day: day,
                      ),
                    ),
                  ),
                ),
              ActionButton(
                themeData: menuButtonTheme,
                child: Icon(
                  AbiliaIcons.edit,
                  size: 32,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return BlocProvider<EditActivityBloc>(
                          create: (_) => EditActivityBloc(
                            activitiesBloc:
                                BlocProvider.of<ActivitiesBloc>(context),
                            activity: activity,
                            day: day,
                          ),
                          child: EditActivityPage(
                            day: day,
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
                    builder: (_) => BlocProvider<UserFileBloc>.value(
                      value: BlocProvider.of<UserFileBloc>(context),
                      child: DeleteActivityDialog(activityOccasion: occasion),
                    ),
                  );
                  if (shouldDelete == true) {
                    if (activity.isRecurring) {
                      final applyTo = await showViewDialog<ApplyTo>(
                        context: context,
                        builder: (context) =>
                            EditRecurrentDialog(allDaysVisible: true),
                      );
                      if (applyTo == null) return;
                      BlocProvider.of<ActivitiesBloc>(context).add(
                        DeleteRecurringActivity(
                          activity,
                          applyTo,
                          occasion.day,
                        ),
                      );
                    } else {
                      BlocProvider.of<ActivitiesBloc>(context)
                          .add(DeleteActivity(activity));
                    }
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
