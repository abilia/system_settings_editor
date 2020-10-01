import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

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
    @required this.editActivityState,
    @required this.day,
  }) : super(key: key);

  final EditActivityState editActivityState;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final activity = editActivityState.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => ListView(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 56.0),
        children: <Widget>[
          separated(ActivityNameAndPictureWidget(editActivityState)),
          separated(DateAndTimeWidget(editActivityState)),
          CollapsableWidget(
            child: separated(CategoryWidget(activity)),
            collapsed:
                activity.fullDay || !memoSettingsState.activityTypeEditable,
          ),
          separated(CheckableAndDeleteAfterWidget(activity)),
          padded(AvailibleForWidget(activity)),
        ],
      ),
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
    final noRecuringDataError =
        state.saveErrors.contains(SaveError.NO_RECURING_DAYS);
    final activity = state.activity;
    final recurs = activity.recurs;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ListView(
        children: <Widget>[
          CollapsableWidget(
            collapsed: activity.fullDay,
            child: separated(
              TimeIntervallPicker(
                state.timeInterval,
                startTimeError:
                    state.saveErrors.contains(SaveError.NO_START_TIME),
              ),
            ),
          ),
          if (recurs.yearly || recurs.once)
            padded(RecurrenceWidget(activity))
          else ...[
            separated(
              Column(
                children: [
                  RecurrenceWidget(activity),
                  SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: noRecuringDataError
                        ? errorBoxDecoration
                        : const BoxDecoration(),
                    padding: noRecuringDataError
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            if (recurs.weekly) WeekDays(activity),
                            if (recurs.monthly) MonthDays(activity),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            padded(EndDateWidget(state)),
          ]
        ],
      ),
    );
  }
}
