import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return VerticalScrollArrows(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        padding:
            EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
        children: <Widget>[
          separatedAndPadded(
            AlarmWidget(activity),
          ),
          padded(
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
        ],
      ),
    );
  }
}
