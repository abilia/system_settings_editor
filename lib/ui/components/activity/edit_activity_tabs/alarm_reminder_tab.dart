import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        return ScrollArrows.vertical(
          controller: scrollController,
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              AlarmWidget(activity).pad(layout.templates.m1.withoutBottom),
              SizedBox(height: layout.formPadding.groupBottomDistance),
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
              ).pad(layout.templates.m1.withoutBottom),
              if (context.read<WizardCubit>()
                  is! TemplateActivityWizardCubit) ...[
                SizedBox(height: layout.formPadding.groupBottomDistance),
                const Divider(),
                RecordSoundWidget(activity: activity)
                    .pad(layout.templates.m1.withoutBottom),
              ],
            ],
          ),
        );
      },
    );
  }
}
