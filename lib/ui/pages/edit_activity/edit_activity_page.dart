import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  final String? title;
  const EditActivityPage({
    this.title,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.activityRecurringEditable !=
          current.activityRecurringEditable,
      builder: (context, memoSettingsState) =>
          BlocBuilder<EditActivityBloc, EditActivityState>(
        builder: (context, state) {
          final activity = state.activity;
          final fullDay = activity.fullDay;
          final displayRecurrence = memoSettingsState.activityRecurringEditable;
          final tabs = [
            MainTab(editActivityState: state),
            if (!fullDay) AlarmAndReminderTab(activity: activity),
            if (displayRecurrence) const RecurrenceTab(),
            InfoItemTab(state: state),
          ];
          return BlocListener<EditActivityBloc, EditActivityState>(
            listenWhen: (_, current) => current.sucessfullSave == true,
            listener: (context, state) => Navigator.of(context).pop(true),
            child: DefaultTabController(
              initialIndex: 0,
              length: tabs.length,
              child: ScrollToErrorPageListener(
                nrTabs: tabs.length,
                child: Scaffold(
                  appBar: AbiliaAppBar(
                    iconData: AbiliaIcons.plus,
                    title: title ?? translate.newActivity,
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
                        Icon(AbiliaIcons.my_photos),
                        Icon(AbiliaIcons.attention),
                        Icon(AbiliaIcons.repeat),
                        Icon(AbiliaIcons.attachment),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: tabs,
                  ),
                  bottomNavigationBar: WizardBottomNavigation(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
