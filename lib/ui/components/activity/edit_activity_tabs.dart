import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

mixin EditActivityTab {
  Widget separated(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120),
        ),
      ),
      child: padded(child),
    );
  }

  Widget padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 24.0, 4.0, 16.0),
      child: child,
    );
  }
}

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({
    Key key,
    @required this.state,
    @required this.day,
  }) : super(key: key);

  final EditActivityState state;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final activity = state.activity;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 56.0),
      children: <Widget>[
        separated(ActivityNameAndPictureWidget(state)),
        separated(DateAndTimeWidget(state)),
        CollapsableWidget(
          child: separated(CategoryWidget(activity)),
          collapsed: activity.fullDay,
        ),
        separated(CheckableAndDeleteAfterWidget(activity)),
        padded(AvailibleForWidget(activity)),
      ],
    );
  }
}

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: <Widget>[
          separated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(Translator.of(context).translate.reminders),
                ReminderSwitch(activity: activity),
                CollapsableWidget(
                  padding: const EdgeInsets.only(top: 8.0),
                  collapsed:
                      activity.fullDay || activity.reminderBefore.isEmpty,
                  child: Reminders(activity: activity),
                ),
              ],
            ),
          ),
          padded(
            AlarmWidget(activity),
          ),
        ],
      ),
    );
  }
}

class RecurrenceTab extends StatelessWidget with EditActivityTab {
  const RecurrenceTab({
    Key key,
    @required this.state,
  }) : super(key: key);

  final EditActivityState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: <Widget>[
          CollapsableWidget(
            collapsed: state.activity.fullDay,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: separated(
              TimeIntervallPicker(
                state.timeInterval,
                startTimeError: state.failedSave && !state.hasStartTime,
              ),
            ),
          ),
          padded(
            RecurrenceWidget(state.activity),
          ),
        ],
      ),
    );
  }
}
