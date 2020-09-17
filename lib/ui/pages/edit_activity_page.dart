import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

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
        final activity = state.activity;
        final fullDay = activity.fullDay;
        final storedRecurring =
            state is StoredActivityState && state.activity.isRecurring;
        final tabs = [
          MainTab(state: state, day: day),
          if (!fullDay) AlarmAndReminderTab(activity: activity),
          if (!storedRecurring) RecurrenceTab(state: state),
          InfoItemTab(state: state),
        ];
        return DefaultTabController(
          initialIndex: 0,
          length: tabs.length,
          child: Scaffold(
            appBar: AbiliaAppBar(
              bottom: AbiliaTabBar(
                collapsedCondition: (i) {
                  switch (i) {
                    case 1:
                      return fullDay;
                    case 2:
                      return storedRecurring;
                    default:
                      return false;
                  }
                },
                tabs: <Widget>[
                  Icon(
                    AbiliaIcons.my_photos,
                    size: smallIconSize,
                  ),
                  Icon(
                    AbiliaIcons.attention,
                    size: smallIconSize,
                  ),
                  Icon(
                    AbiliaIcons.repeat,
                    size: smallIconSize,
                  ),
                  Icon(
                    AbiliaIcons.attachment,
                    size: smallIconSize,
                  ),
                ],
              ),
              title: title,
              trailing: Builder(
                  builder: (context) => ActionButton(
                      key: TestKey.finishEditActivityButton,
                      child: Icon(AbiliaIcons.ok, size: 32),
                      onPressed: () => _finishedPressed(context, state))),
            ),
            body: TabBarView(children: tabs),
          ),
        );
      },
    );
  }

  Future _finishedPressed(BuildContext context, EditActivityState state) async {
    if (state.canSave) {
      if (state is StoredActivityState && state.activity.isRecurring) {
        final applyTo = await showViewDialog<ApplyTo>(
          context: context,
          builder: (context) => EditRecurrentDialog(),
        );
        if (applyTo == null) return;
        BlocProvider.of<EditActivityBloc>(context)
            .add(SaveRecurringActivity(applyTo, state.day));
      } else {
        BlocProvider.of<EditActivityBloc>(context).add(SaveActivity());
      }
      await Navigator.of(context).maybePop();
    } else {
      _scrollToStart(context);
      final translate = Translator.of(context).translate;

      BlocProvider.of<EditActivityBloc>(context).add(SaveActivity());
      if (!state.hasTitleOrImage && !state.hasStartTime) {
        await showErrorViewDialog(
          translate.missingTitleOrImageAndStartTime,
          context: context,
        );
      } else if (!state.hasTitleOrImage) {
        await showErrorViewDialog(
          translate.missingTitleOrImage,
          context: context,
        );
      } else {
        await showErrorViewDialog(
          translate.missingStartTime,
          context: context,
        );
      }
    }
  }

  void _scrollToStart(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    if (tabController.index != 0) {
      tabController.animateTo(0);
    } else {
      final scrollController = PrimaryScrollController.of(context);
      if (scrollController != null) {
        scrollController.animateTo(0.0,
            duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }
}
