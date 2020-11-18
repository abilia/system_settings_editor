import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;

  ActivityPage({Key key, @required this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activityOccasion = occasion.fromActivitiesState(state);
        return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, memoSettingsState) => AnimatedTheme(
            data: weekDayThemes[memoSettingsState.calendarDayColor]
                [occasion.day.weekday],
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
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
          final displayDeleteButton = memoSettingsState.displayDeleteButton;
          final displayEditButton = memoSettingsState.displayEditButton;
          final displayAlarmButton =
              memoSettingsState.displayAlarmButton && !activity.fullDay;
          final numberOfButtons = [
            displayDeleteButton,
            displayEditButton,
            displayAlarmButton,
          ].where((b) => b).length;

          final padding = [0.0, 0.0, 70.0, 39.0][numberOfButtons];
          return BottomAppBar(
            child: SizedBox(
              height: numberOfButtons == 0 ? 0 : 64,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: numberOfButtons == 1
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (displayAlarmButton)
                      ActionButton(
                        key: TestKey.editAlarm,
                        child: Icon(activity.alarm.iconData()),
                        onPressed: () async {
                          final alarm = activity.alarm;
                          final result = await showViewDialog<Alarm>(
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
                    if (displayEditButton)
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
                                        BlocProvider.of<ActivitiesBloc>(
                                            context),
                                    clockBloc:
                                        BlocProvider.of<ClockBloc>(context),
                                    memoplannerSettingBloc:
                                        BlocProvider.of<MemoplannerSettingBloc>(
                                            context),
                                  ),
                                  child: EditActivityPage(
                                    day: activityOccasion.day,
                                    title: Translator.of(context)
                                        .translate
                                        .editActivity,
                                  ),
                                );
                              },
                              settings: RouteSettings(
                                  name: 'EditActivityPage ${activityOccasion}'),
                            ),
                          );
                        },
                      ),
                    if (displayDeleteButton)
                      ActionButton(
                        child: Icon(AbiliaIcons.delete_all_clear),
                        onPressed: () async {
                          final shouldDelete = await showViewDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmActivityActionDialog(
                              activityOccasion: activityOccasion,
                              title: Translator.of(context)
                                  .translate
                                  .deleteActivity,
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
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
