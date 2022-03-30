import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  const EditActivityPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (state) => state.settings.addActivity.addRecurringActivity,
      builder: (context, displayRecurrence) =>
          BlocBuilder<EditActivityCubit, EditActivityState>(
        buildWhen: (previous, current) =>
            previous.activity.fullDay != current.activity.fullDay,
        builder: (context, state) {
          final fullDay = state.activity.fullDay;
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
        },
      ),
    );
  }
}
