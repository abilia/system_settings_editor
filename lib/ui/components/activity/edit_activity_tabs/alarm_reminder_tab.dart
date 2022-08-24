import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({
    required this.showAlarm,
    required this.showReminders,
    required this.showSpeech,
    Key? key,
  }) : super(key: key);

  final bool showAlarm, showReminders, showSpeech;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final activity = context.watch<EditActivityCubit>().state.activity;

    final listItems = [
      if (showAlarm) AlarmWidget(activity),
      if (showReminders)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(Translator.of(context).translate.reminders),
            ReminderSwitch(activity: activity),
            CollapsableWidget(
              padding:
                  EdgeInsets.only(top: layout.formPadding.verticalItemDistance),
              collapsed: activity.fullDay || activity.reminderBefore.isEmpty,
              child: Reminders(activity: activity),
            ),
          ],
        ),
      if (showSpeech) RecordSoundWidget(activity: activity),
    ].map((e) => e.pad(layout.templates.m1.withoutBottom)).toList();

    return ScrollArrows.vertical(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: listItems.length,
        itemBuilder: (context, i) => listItems[i],
        separatorBuilder: (context, i) => Column(
          children: [
            SizedBox(height: layout.formPadding.groupBottomDistance),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
