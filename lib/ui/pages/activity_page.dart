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

class ActivityPage extends StatefulWidget {
  final ActivityOccasion occasion;

  const ActivityPage({Key key, @required this.occasion}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState(occasion);
}

class _ActivityPageState extends State<ActivityPage> {
  final ActivityOccasion occasion;
  final ThemeData dayThemeData;

  _ActivityPageState(this.occasion)
      : dayThemeData = weekDayTheme[occasion.day.weekday];

  bool inDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activity =
            state.newActivityFromLoadedOrGiven(widget.occasion.activity);
        final day = widget.occasion.day;
        return AnimatedTheme(
          data: inDeleteMode ? deleteActivityThemeData : dayThemeData,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(68),
              child: AnimatedSwitcher(
                duration: 200.milliseconds(),
                child: inDeleteMode
                    ? DeleteAppBar(
                        activity: activity,
                        onClosedPressed: () =>
                            setState(() => inDeleteMode = false),
                      )
                    : DayAppBar(
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
            bottomNavigationBar: CollapsableWidget(
              child: buildBottomAppBar(activity, context),
              collapsed: inDeleteMode,
            ),
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
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (innerContext) {
                        final addActivitybloc = AddActivityBloc(
                          activitiesBloc:
                              BlocProvider.of<ActivitiesBloc>(context),
                          activity: activity,
                          newActivity: false,
                        );
                        return BlocProvider<AddActivityBloc>(
                          create: (context) => addActivitybloc,
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
                onPressed: () => setState(() => inDeleteMode = true),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAppBar extends StatelessWidget {
  const DeleteAppBar({
    Key key,
    @required this.activity,
    @required this.onClosedPressed,
  }) : super(key: key);

  final Activity activity;
  final Function onClosedPressed;

  @override
  Widget build(BuildContext context) {
    return AbiliaAppBar(
      title: Translator.of(context).translate.deleteActivity,
      onClosedPressed: onClosedPressed,
      trailing: ActionButton(
        key: TestKey.confirmDelete,
        child: Icon(
          AbiliaIcons.ok,
          size: 32,
        ),
        onPressed: () async {
          BlocProvider.of<ActivitiesBloc>(context)
              .add(DeleteActivity(activity));
          await Navigator.of(context).maybePop();
        },
      ),
    );
  }
}
