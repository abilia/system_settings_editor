import 'package:flutter/widgets.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';


class MainTab extends StatefulWidget {
  MainTab({
    Key key,
    @required this.editActivityState,
    @required this.memoplannerSettingsState,
    @required this.day,
  }) : super(key: key);

  final EditActivityState editActivityState;
  final MemoplannerSettingsState memoplannerSettingsState;
  final DateTime day;

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with EditActivityTab {
  ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.editActivityState.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => VerticalScrollArrows(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding:
              EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
          children: <Widget>[
            separatedAndPadded(
                ActivityNameAndPictureWidget(widget.editActivityState)),
            separatedAndPadded(DateAndTimeWidget(widget.editActivityState)),
            if (widget.memoplannerSettingsState.showCategories)
              CollapsableWidget(
                child: separatedAndPadded(CategoryWidget(activity)),
                collapsed:
                    activity.fullDay || !memoSettingsState.activityTypeEditable,
              ),
            separatedAndPadded(CheckableAndDeleteAfterWidget(activity)),
            padded(AvailibleForWidget(activity)),
          ],
        ),
      ),
    );
  }
}

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return VerticalScrollArrows(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        padding:
            EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
        children: <Widget>[
          separatedAndPadded(
            AlarmWidget(activity),
          ),
          padded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(Translator.of(context).translate.reminders),
                ReminderSwitch(activity: activity),
                CollapsableWidget(
                  padding: const EdgeInsets.only(top: 8.0),
                  collapsed:
                      activity.fullDay || activity.reminderBefore.isEmpty,
                  child: Reminders(activity: activity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
