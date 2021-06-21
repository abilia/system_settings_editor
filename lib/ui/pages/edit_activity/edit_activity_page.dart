// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  static PageRoute<bool> route(BuildContext context, DateTime day,
          [BasicActivityData basicActivity]) =>
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: BlocProvider<EditActivityBloc>(
            create: (_) => EditActivityBloc.newActivity(
              activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
              clockBloc: BlocProvider.of<ClockBloc>(context),
              memoplannerSettingBloc:
                  BlocProvider.of<MemoplannerSettingBloc>(context),
              day: day,
              basicActivityData: basicActivity,
            ),
            child: EditActivityPage(
              day: day,
              title: Translator.of(context).translate.newActivity,
            ),
          ),
        ),
        settings: RouteSettings(name: '$EditActivityPage new activity'),
      );

  final DateTime day;
  final String title;
  const EditActivityPage({
    @required this.day,
    this.title,
    Key key,
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
            MainTab(
              editActivityState: state,
              day: day,
            ),
            if (!fullDay) AlarmAndReminderTab(activity: activity),
            if (displayRecurrence) const RecurrenceTab(),
            InfoItemTab(state: state),
          ];
          return DefaultTabController(
            initialIndex: 0,
            length: tabs.length,
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
              body: EditActivityListeners(
                nrTabs: tabs.length,
                child: TabBarView(children: tabs),
              ),
              bottomNavigationBar: BottomNavigation(
                backNavigationWidget: const PreviousButton(),
                forwardNavigationWidget: GreenButton(
                  key: TestKey.finishEditActivityButton,
                  icon: AbiliaIcons.ok,
                  text: translate.save,
                  onPressed: () => BlocProvider.of<EditActivityBloc>(context)
                      .add(SaveActivity()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
