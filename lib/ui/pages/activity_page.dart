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
              child: Icon(AbiliaIcons.navigation_previous),
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
                      child: Icon(AbiliaIcons.handi_uncheck),
                    ),
                  if (displayAlarmButton)
                    ActionButtonLight(
                      key: TestKey.editAlarm,
                      onPressed: () async {
                        final alarm = activity.alarm;

                        final result = await Navigator.of(context).push<Alarm>(
                          MaterialPageRoute(
                            builder: (_) => CopiedAuthProviders(
                              blocContext: context,
                              child: SelectAlarmPage(
                                alarm: alarm,
                              ),
                            ),
                            settings: RouteSettings(name: 'SelectAlarmPage'),
                          ),
                        );

                        if (result != null) {
                          final changedActivity =
                              activity.copyWith(alarm: result);
                          if (activity.isRecurring) {
                            final applyTo = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (_) => SelectRecurrentTypePage(
                                heading: Translator.of(context)
                                    .translate
                                    .editRecurringActivity,
                                headingIcon: AbiliaIcons.edit,
                              ),
                            ));
                            if (applyTo == null) return;
                            BlocProvider.of<ActivitiesBloc>(context).add(
                              UpdateRecurringActivity(
                                ActivityDay(
                                  changedActivity,
                                  activityOccasion.day,
                                ),
                                applyTo,
                              ),
                            );
                          } else {
                            BlocProvider.of<ActivitiesBloc>(context)
                                .add(UpdateActivity(changedActivity));
                          }
                        }
                      },
                      child: Icon(activity.alarm.iconData()),
                    ),
                  if (displayDeleteButton)
                    ActionButtonLight(
                      onPressed: () async {
                        final shouldDelete = await showViewDialog<bool>(
                          context: context,
                          builder: (_) => YesNoDialog(
                            heading: Translator.of(context).translate.remove,
                            headingIcon: AbiliaIcons.delete_all_clear,
                            text:
                                Translator.of(context).translate.deleteActivity,
                          ),
                        );
                        if (shouldDelete == true) {
                          if (activity.isRecurring) {
                            final applyTo = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (_) => SelectRecurrentTypePage(
                                heading: Translator.of(context)
                                    .translate
                                    .deleteRecurringActivity,
                                allDaysVisible: true,
                                headingIcon: AbiliaIcons.delete_all_clear,
                              ),
                            ));
                            if (applyTo == null) return;
                            BlocProvider.of<ActivitiesBloc>(context).add(
                              DeleteRecurringActivity(
                                activityOccasion,
                                applyTo,
                              ),
                            );
                          } else {
                            BlocProvider.of<ActivitiesBloc>(context)
                                .add(DeleteActivity(activity));
                          }
                          await Navigator.of(context).maybePop();
                        }
                      },
                      child: Icon(AbiliaIcons.delete_all_clear),
                    ),
                  if (displayEditButton)
                    ActionButtonLight(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CopiedAuthProviders(
                              blocContext: context,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => ActivityWizardCubit(),
                                  ),
                                  BlocProvider<EditActivityBloc>(
                                    create: (_) => EditActivityBloc(
                                      activityOccasion,
                                      activitiesBloc:
                                          context.read<ActivitiesBloc>(),
                                      clockBloc: context.read<ClockBloc>(),
                                      memoplannerSettingBloc: context
                                          .read<MemoplannerSettingBloc>(),
                                    ),
                                  ),
                                ],
                                child: ErrorPopupListener(
                                  child: EditActivityPage(
                                    title: Translator.of(context)
                                        .translate
                                        .editActivity,
                                  ),
                                ),
                              ),
                            ),
                            settings: RouteSettings(
                                name: '$EditActivityPage $activityOccasion'),
                          ),
                        );
                      },
                      child: Icon(AbiliaIcons.edit),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
