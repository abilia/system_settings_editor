import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class EditActivityPage extends StatelessWidget {
  final DateTime day;
  final String title;
  const EditActivityPage({
    @required this.day,
    this.title = '',
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) {
        final fullDay = state.activity.fullDay;
        return DefaultTabController(
          initialIndex: 0,
          length: 3 + (fullDay ? 0 : 1),
          child: Scaffold(
            appBar: AbiliaAppBar(
              bottom: AbiliaTabBar(
                collapsedCondition: (i) {
                  switch (i) {
                    case 1:
                      return fullDay;
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
              title: title,
              trailing: ActionButton(
                key: TestKey.finishEditActivityButton,
                child: Icon(
                  AbiliaIcons.ok,
                  size: 32,
                ),
                onPressed: state.canSave
                    ? () async {
                        if (state is StoredActivityState &&
                            state.activity.isRecurring) {
                          final applyTo = await showViewDialog<ApplyTo>(
                            context: context,
                            builder: (context) => EditRecurrentDialog(),
                          );
                          if (applyTo == null) return;
                          BlocProvider.of<EditActivityBloc>(context)
                              .add(SaveRecurringActivity(applyTo, state.day));
                        } else {
                          BlocProvider.of<EditActivityBloc>(context)
                              .add(SaveActivity());
                        }
                        await Navigator.of(context).maybePop();
                      }
                    : null,
              ),
            ),
            body: TabBarView(children: [
              MainTab(state: state, day: day),
              if (!fullDay) AlarmAndReminderTab(activity: state.activity),
              UnderConstruction(),
              UnderConstruction(),
            ]),
          ),
        );
      },
    );
  }
}

class UnderConstruction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      alignment: Alignment.topRight,
      scale: 3,
      child: Banner(
        location: BannerLocation.topEnd,
        color: AbiliaColors.red,
        message: 'Under construction',
      ),
    );
  }
}

class MainTab extends EditActivityTab {
  const MainTab({
    Key key,
    @required this.state,
    @required this.day,
  }) : super(key: key);

  final EditActivityState state;
  final DateTime day;

  @override
  List<Widget> buildChildren(BuildContext context) {
    final activity = state.activity;
    return <Widget>[
      separated(
        NameAndPictureWidget(
          activity,
          day: day,
          newImage: state.newImage,
        ),
      ),
      separated(DateAndTimeWidget(activity, state.timeInterval, day: day)),
      CollapsableWidget(
        child: separated(CategoryWidget(activity)),
        collapsed: activity.fullDay,
      ),
      separated(CheckableAndDeleteAfterWidget(activity)),
      padded(AvailibleForWidget(activity)),
    ];
  }
}

class AlarmAndReminderTab extends EditActivityTab {
  const AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  List<Widget> buildChildren(BuildContext context) {
    return <Widget>[
      separated(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(Translator.of(context).translate.reminders),
            ReminderSwitch(activity: activity),
            CollapsableWidget(
              padding: const EdgeInsets.only(top: 8.0),
              collapsed: activity.fullDay || activity.reminderBefore.isEmpty,
              child: Reminders(activity: activity),
            ),
          ],
        ),
      ),
      padded(
        AlarmWidget(activity),
      ),
    ];
  }
}

abstract class EditActivityTab extends StatelessWidget {
  const EditActivityTab({Key key}) : super(key: key);

  List<Widget> buildChildren(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 56.0),
      children: buildChildren(context),
    );
  }

  Widget separated(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120),
        ),
      ),
      child: padded(child),
    );
  }

  Widget padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 24.0, 4.0, 16.0),
      child: child,
    );
  }
}
