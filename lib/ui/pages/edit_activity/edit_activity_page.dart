import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  const EditActivityPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.activityRecurringEditable !=
          current.activityRecurringEditable,
      builder: (context, memoSettingsState) =>
          BlocBuilder<EditActivityBloc, EditActivityState>(
        buildWhen: (previous, current) =>
            previous.activity.fullDay != current.activity.fullDay,
        builder: (context, state) {
          final fullDay = state.activity.fullDay;
          final displayRecurrence = memoSettingsState.activityRecurringEditable;
          final tabs = [
            const MainTab(),
            if (!fullDay) const AlarmAndReminderTab(),
            if (displayRecurrence) const RecurrenceTab(),
            const InfoItemTab(),
          ];
          return DefaultTabController(
            initialIndex: 0,
            length: tabs.length,
            child: ScrollToErrorPageListener(
              nrTabs: tabs.length,
              child: Scaffold(
                appBar: AbiliaAppBar(
                  iconData: AbiliaIcons.plus,
                  title: state is StoredActivityState
                      ? translate.editActivity
                      : translate.newActivity,
                  bottom: AbiliaTabBar(
                    collapsedCondition: (i) {
                      switch (i) {
                        case 1:
                          return fullDay;
                        case 2:
                          return !displayRecurrence;
                        default:
                          return false;
                      }
                    },
                    tabs: const <Widget>[
                      Icon(AbiliaIcons.myPhotos),
                      Icon(AbiliaIcons.attention),
                      Icon(AbiliaIcons.repeat),
                      Icon(AbiliaIcons.attachment),
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
        },
      ),
    );
  }
}
