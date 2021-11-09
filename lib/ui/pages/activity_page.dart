import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityPage extends StatelessWidget {
  final ActivityOccasion occasion;
  final Widget? previewImage;

  const ActivityPage({
    Key? key,
    required this.occasion,
    this.previewImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final activityOccasion = occasion.fromActivitiesState(state);
        return Scaffold(
          appBar: DayAppBar(
            day: activityOccasion.activity.isRecurring
                ? activityOccasion.day
                : activityOccasion.activity.startTime,
            leftAction: ActionButton(
              key: TestKey.activityBackButton,
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(AbiliaIcons.navigationPrevious),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(ActivityInfo.margin)
                .subtract(EdgeInsets.only(left: ActivityInfo.margin)),
            child: ActivityInfoWithDots(
              activityOccasion,
              previewImage: previewImage,
            ),
          ),
          bottomNavigationBar:
              ActivityBottomAppBar(activityOccasion: activityOccasion),
        );
      },
    );
  }
}

class ActivityBottomAppBar extends StatelessWidget with ActivityMixin {
  const ActivityBottomAppBar({
    Key? key,
    required this.activityOccasion,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) {
        final displayDeleteButton = memoSettingsState.displayDeleteButton;
        final displayEditButton = memoSettingsState.displayEditButton;
        final displayAlarmButton =
            memoSettingsState.displayAlarmButton && !activity.fullDay;
        final displayUncheckButton = activityOccasion.isSignedOff;
        final numberOfButtons = [
          displayDeleteButton,
          displayEditButton,
          displayAlarmButton,
          displayUncheckButton,
        ].where((b) => b).length;

        final padding = [0.0, 0.0, 70.0.s, 39.0.s, 23.0.s][numberOfButtons];
        return BottomAppBar(
          child: SizedBox(
            height: numberOfButtons == 0 ? 0 : 64.s,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: numberOfButtons == 1
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (displayUncheckButton)
                    ActionButtonLight(
                      key: TestKey.uncheckButton,
                      onPressed: () async {
                        await checkConfirmation(
                          context,
                          activityOccasion,
                        );
                      },
                      child: const Icon(AbiliaIcons.handiUncheck),
                    ),
                  if (displayAlarmButton)
                    ActionButtonLight(
                      key: TestKey.editAlarm,
                      onPressed: () => _alarmButtonPressed(
                        context,
                        activityOccasion,
                      ),
                      child: Icon(activity.alarm.iconData()),
                    ),
                  if (displayDeleteButton)
                    ActionButtonLight(
                      onPressed: () => _deleteButtonPressed(
                        context,
                        activity,
                      ),
                      child: const Icon(AbiliaIcons.deleteAllClear),
                    ),
                  if (displayEditButton)
                    EditActivityButton(
                      activityOccasion: activityOccasion,
                      settings: memoSettingsState,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _alarmButtonPressed(
    BuildContext context,
    ActivityOccasion activityOccasion,
  ) async {
    final activity = activityOccasion.activity;
    final result = await Navigator.of(context).push<Activity>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: BlocProvider<EditActivityBloc>(
            create: (_) => EditActivityBloc.edit(activityOccasion),
            child: SelectAlarmPage(activity: activity),
          ),
        ),
        settings: const RouteSettings(name: 'SelectAlarmPage'),
      ),
    );

    if (result != null) {
      final activitiesBloc = context.read<ActivitiesBloc>();
      if (activity.isRecurring ||
          activitiesBloc.state.isPartOfSeries(activity)) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          MaterialPageRoute(
            builder: (_) => SelectRecurrentTypePage(
              heading: Translator.of(context).translate.editRecurringActivity,
              headingIcon: AbiliaIcons.edit,
            ),
          ),
        );
        if (applyTo == null) return;
        activitiesBloc.add(
          UpdateRecurringActivity(
            ActivityDay(
              result,
              activityOccasion.day,
            ),
            applyTo,
          ),
        );
      } else {
        activitiesBloc.add(UpdateActivity(result));
      }
    }
  }

  Future<void> _deleteButtonPressed(
    BuildContext context,
    Activity activity,
  ) async {
    final shouldDelete = await showViewDialog<bool>(
      context: context,
      builder: (_) => YesNoDialog(
        heading: Translator.of(context).translate.remove,
        headingIcon: AbiliaIcons.deleteAllClear,
        text: Translator.of(context).translate.deleteActivity,
      ),
    );
    if (shouldDelete == true) {
      final activitiesBloc = context.read<ActivitiesBloc>();
      if (activity.isRecurring ||
          activitiesBloc.state.isPartOfSeries(activity)) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          MaterialPageRoute(
            builder: (_) => SelectRecurrentTypePage(
              heading: Translator.of(context).translate.deleteRecurringActivity,
              allDaysVisible: true,
              headingIcon: AbiliaIcons.deleteAllClear,
            ),
          ),
        );
        if (applyTo == null) return;
        activitiesBloc.add(
          DeleteRecurringActivity(
            activityOccasion,
            applyTo,
          ),
        );
      } else {
        activitiesBloc.add(DeleteActivity(activity));
      }
      await Navigator.of(context).maybePop();
    }
  }
}

class EditActivityButton extends StatelessWidget {
  const EditActivityButton({
    Key? key,
    required this.activityOccasion,
    required this.settings,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final MemoplannerSettingsState settings;

  @override
  Widget build(BuildContext context) {
    return ActionButtonLight(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<EditActivityBloc>(
                    create: (_) => EditActivityBloc.edit(activityOccasion),
                  ),
                  BlocProvider(
                    create: (context) => ActivityWizardCubit.edit(
                      activitiesBloc: context.read<ActivitiesBloc>(),
                      editActivityBloc: context.read<EditActivityBloc>(),
                      clockBloc: context.read<ClockBloc>(),
                      settings: settings,
                    ),
                  ),
                ],
                child: const ActivityWizardPage(),
              ),
            ),
            settings:
                RouteSettings(name: '$ActivityWizardPage $activityOccasion'),
          ),
        );
      },
      child: const Icon(AbiliaIcons.edit),
    );
  }
}
