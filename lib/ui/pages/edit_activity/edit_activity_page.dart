import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

enum EditActivityPageTab { main, alarm, recurrence, infoItem }

class EditActivityPage extends StatelessWidget {
  const EditActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final generalSettings = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.addActivity.general);
    final editActivitySettings = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.addActivity.editActivity);
    final addRecurringActivity = generalSettings.addRecurringActivity;
    final fullDay =
        context.select((EditActivityCubit bloc) => bloc.state.activity.fullDay);
    final showChecklists = editActivitySettings.checklist;
    final showNotes = editActivitySettings.notes;
    final showSpeech =
        context.read<WizardCubit>() is! TemplateActivityWizardCubit &&
            generalSettings.showSpeechAtAlarm;
    final showAlarm = editActivitySettings.alarm;
    final showReminders = editActivitySettings.reminders;
    final showAlarmTab = !fullDay && (showAlarm || showReminders || showSpeech);
    final showRecurrenceTab = addRecurringActivity &&
        context.read<WizardCubit>() is! TemplateActivityWizardCubit;
    final showInfoItemTab = showChecklists || showNotes;
    final showTabs = showAlarmTab || showRecurrenceTab || showInfoItemTab;

    final enabledTabs = [
      EditActivityPageTab.main,
      if (showAlarmTab) EditActivityPageTab.alarm,
      if (showRecurrenceTab) EditActivityPageTab.recurrence,
      if (showInfoItemTab) EditActivityPageTab.infoItem
    ];

    final tabWidgets = [
      const MainTab(),
      if (showAlarmTab)
        AlarmAndReminderTab(
          showAlarm: showAlarm,
          showReminders: showReminders,
          showSpeech: showSpeech,
        ),
      if (showRecurrenceTab) const RecurrenceTab(),
      if (showInfoItemTab)
        InfoItemTab(
          showChecklist: showChecklists,
          showNote: showNotes,
        ),
    ];

    return DefaultTabController(
      initialIndex: 0,
      length: tabWidgets.length,
      child: ScrollToErrorPageListener(
        enabledTabs: enabledTabs,
        child: Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.plus,
            title: getTitle(context),
            bottom: showTabs
                ? AbiliaTabBar(
                    collapsedCondition: (i) {
                      switch (i) {
                        case 1:
                          return !showAlarmTab;
                        case 2:
                          return !showRecurrenceTab;
                        case 3:
                          return !showInfoItemTab;
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
                  )
                : null,
          ),
          body: TabBarView(children: tabWidgets),
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
