import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        return ScrollArrows.vertical(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              AlarmWidget(activity).pad(m1TopPadding),
              SizedBox(height: layout.formPadding.dividerTopDistance),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SubHeading(Translator.of(context).translate.reminders),
                  ReminderSwitch(activity: activity),
                  CollapsableWidget(
                    padding: EdgeInsets.only(
                        top: layout.formPadding.verticalItemDistance),
                    collapsed:
                        activity.fullDay || activity.reminderBefore.isEmpty,
                    child: Reminders(activity: activity),
                  ),
                ],
              ).pad(m1TopPadding),
              SizedBox(height: layout.formPadding.dividerTopDistance),
              const Divider(),
              RecordSoundWidget(activity: activity).pad(m1TopPadding),
            ],
          ),
        );
      },
    );
  }
}
