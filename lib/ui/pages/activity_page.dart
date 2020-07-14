import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
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
        final activityOccasion = occasion.fromActivitiesState(state);
        return AnimatedTheme(
          data: dayThemeData,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(68),
              child: AnimatedSwitcher(
                duration: 200.milliseconds(),
                child: DayAppBar(
                  day: activityOccasion.day,
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
              padding: const EdgeInsets.all(ActivityInfo.margin)
                  .subtract(const EdgeInsets.only(left: ActivityInfo.margin)),
              child: ActivityInfoWithDots(activityOccasion),
            ),
            bottomNavigationBar:
                ActivityBottomAppBar(activityOccasion: activityOccasion),
          ),
        );
      },
    );
  }
}

class ActivityBottomAppBar extends StatelessWidget {
  const ActivityBottomAppBar({
    Key key,
    @required this.activityOccasion,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    return Theme(
      data: bottomNavigationBarTheme,
      child: BottomAppBar(
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
                    child: Icon(activity.alarm.iconData()),
                    onPressed: () async {
                      final alarm = activity.alarm;
                      final result = await showViewDialog<AlarmType>(
                        context: context,
                        builder: (context) => SelectAlarmDialog(
                          alarm: alarm,
                        ),
                      );
                      if (result != null) {
                        final changedActivity =
                            activity.copyWith(alarm: result);
                        if (activity.isRecurring) {
                          final applyTo = await showViewDialog<ApplyTo>(
                            context: context,
                            builder: (context) => EditRecurrentDialog(),
                          );
                          if (applyTo == null) return;
                          BlocProvider.of<ActivitiesBloc>(context).add(
                            UpdateRecurringActivity(
                              ActivityDay(
                                changedActivity,
                                activityOccasion.day,
                              ),
                              applyTo,
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
                    child: Icon(AbiliaIcons.handi_reminder),
                    onPressed: () => showViewDialog<bool>(
                      context: context,
                      builder: (_) => BlocProvider<EditActivityBloc>.value(
                        value: EditActivityBloc(activityOccasion,
                            activitiesBloc:
                                BlocProvider.of<ActivitiesBloc>(context)),
                        child:
                            SelectReminderDialog(activityDay: activityOccasion),
                      ),
                    ),
                  ),
                ActionButton(
                  child: Icon(AbiliaIcons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return BlocProvider<EditActivityBloc>(
                            create: (_) => EditActivityBloc(
                              activityOccasion,
                              activitiesBloc:
                                  BlocProvider.of<ActivitiesBloc>(context),
                            ),
                            child: EditActivityPage(
                              day: activityOccasion.day,
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
                  child: Icon(AbiliaIcons.delete_all_clear),
                  onPressed: () async {
                    final shouldDelete = await showViewDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmActivityActionDialog(
                        activityOccasion: activityOccasion,
                        title: Translator.of(context).translate.deleteActivity,
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
                            activityOccasion,
                            applyTo,
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
      ),
    );
  }
}
