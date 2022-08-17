import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  const EditActivityPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final addRecurringActivity = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.addActivity.addRecurringActivity);
    final showRecurrence = addRecurringActivity &&
        context.read<WizardCubit>() is! TemplateActivityWizardCubit;
    final fullDay =
        context.select((EditActivityCubit bloc) => bloc.state.activity.fullDay);
    final showChecklists = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.editActivity.checklist);
    final showNotes = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.editActivity.notes);
    final showSpeech =
        context.read<WizardCubit>() is! TemplateActivityWizardCubit;
    final showAlarm = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.editActivity.alarm);
    final showReminders = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.editActivity.reminders);
    final showAlarmTab = !fullDay && (showAlarm || showReminders || showSpeech);

    final tabs = [
      const MainTab(),
      if (showAlarmTab)
        AlarmAndReminderTab(
          showAlarm: showAlarm,
          showReminders: showReminders,
          showSpeech: showSpeech,
        ),
      if (showRecurrence) const RecurrenceTab(),
      if (showChecklists || showNotes)
        InfoItemTab(
          showChecklist: showChecklists,
          showNote: showNotes,
        ),
    ];

    return DefaultTabController(
      initialIndex: 0,
      length: tabs.length,
      child: ScrollToErrorPageListener(
        nrTabs: tabs.length,
        child: Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.plus,
            title: getTitle(context),
            bottom: AbiliaTabBar(
              collapsedCondition: (i) {
                switch (i) {
                  case 1:
                    return !showAlarmTab;
                  case 2:
                    return !showRecurrence;
                  case 3:
                    return !showChecklists && !showNotes;
                  default:
                    return false;
                }
              },
              tabs: <Widget>[
                TabItem(translate.name, AbiliaIcons.myPhotos),
                TabItem(translate.alarm, AbiliaIcons.attention),
                TabItem(translate.recurrence, AbiliaIcons.repeat),
                TabItem(translate.extra, AbiliaIcons.attachment),
              ],
            ),
          ),
          body: TabBarView(
            children: tabs,
          ),
          bottomNavigationBar: const WizardBottomNavigation(),
        ),
      ),
    );
  }

  String getTitle(BuildContext context) {
    final translate = Translator.of(context).translate;
    final isTemplate =
        context.read<WizardCubit>() is TemplateActivityWizardCubit;
    final isEdit =
        context.read<EditActivityCubit>().state is StoredActivityState;
    if (isTemplate) {
      if (isEdit) return translate.editActivity;
      return translate.newActivity;
    }
    if (isEdit) return translate.editActivity;
    return translate.newActivity;
  }
}
