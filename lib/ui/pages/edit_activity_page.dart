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
    this.title,
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) =>
          BlocBuilder<EditActivityBloc, EditActivityState>(
        builder: (context, state) {
          final activity = state.activity;
          final fullDay = activity.fullDay;
          final storedRecurring =
              state is StoredActivityState && state.activity.isRecurring;
          final displayRecurrence =
              !storedRecurring && memoSettingsState.activityRecurringEditable;
          final tabs = [
            MainTab(editActivityState: state, day: day),
            if (!fullDay) AlarmAndReminderTab(activity: activity),
            if (displayRecurrence) RecurrenceTab(state: state),
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
                        return !displayRecurrence;
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
      ),
    );
  }

  Future _finishedPressed(BuildContext context, EditActivityState state) async {
    if (state is StoredActivityState && state.unchanged) {
      await Navigator.of(context).maybePop();
      return;
    }

    final errors = BlocProvider.of<EditActivityBloc>(context).canSave;
    if (errors.isEmpty) {
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
      if (errors.contains(SaveError.NO_TITLE_OR_IMAGE) &&
          errors.contains(SaveError.NO_START_TIME)) {
        await showErrorViewDialog(
          translate.missingTitleOrImageAndStartTime,
          context: context,
        );
      } else if (errors.contains(SaveError.NO_TITLE_OR_IMAGE)) {
        await showErrorViewDialog(
          translate.missingTitleOrImage,
          context: context,
        );
      } else if (errors.contains(SaveError.NO_START_TIME)) {
        await showErrorViewDialog(
          translate.missingStartTime,
          context: context,
        );
      } else if (errors.contains(SaveError.START_TIME_BEFORE_NOW)) {
        await showErrorViewDialog(
          translate.startTimeBeforeNow,
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
