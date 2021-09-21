import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/activity/record_sound_widgets.dart';

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        return VerticalScrollArrows(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            padding:
                EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
            children: <Widget>[
              separatedAndPadded(AlarmWidget(activity)),
              separatedAndPadded(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SubHeading(Translator.of(context).translate.reminders),
                    ReminderSwitch(activity: activity),
                    CollapsableWidget(
                      padding: EdgeInsets.only(top: 8.0.s),
                      collapsed:
                          activity.fullDay || activity.reminderBefore.isEmpty,
                      child: Reminders(activity: activity),
                    ),
                  ],
                ),
              ),
              padded(RecordSoundWidget(activity)),
            ],
          ),
        );
      },
    );
  }
}
