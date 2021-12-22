import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityPage extends StatelessWidget {
  final ActivityDay activityDay;
  final Widget? previewImage;

  const ActivityPage({
    Key? key,
    required this.activityDay,
    this.previewImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActivitiesBloc, ActivitiesState, ActivityDay>(
      selector: (activitiesState) {
        final a =
            activitiesState.newActivityFromLoadedOrGiven(activityDay.activity);
        return ActivityDay(
          a,
          a.isRecurring ? activityDay.day : a.startTime,
        );
      },
      builder: (context, ad) {
        return Scaffold(
          appBar: DayAppBar(
            day: ad.day,
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
              ad,
              previewImage: previewImage,
            ),
          ),
          bottomNavigationBar: ActivityBottomAppBar(activityDay: ad),
        );
      },
    );
  }
}

class ActivityBottomAppBar extends StatelessWidget with ActivityMixin {
  const ActivityBottomAppBar({
    Key? key,
    required this.activityDay,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) {
        final displayDeleteButton = memoSettingsState.displayDeleteButton;
        final displayEditButton = memoSettingsState.displayEditButton;
        final displayAlarmButton =
            memoSettingsState.displayAlarmButton && !activity.fullDay;
        final displayUncheckButton = activityDay.isSignedOff;
        final numberOfButtons = [
          displayDeleteButton,
          displayEditButton,
          displayAlarmButton,
          displayUncheckButton,
        ].where((b) => b).length;

        final padding = layout.toolbar.itemsPaddings[numberOfButtons];
        return BottomAppBar(
          child: SizedBox(
            height: numberOfButtons == 0 ? 0 : layout.toolbar.heigth,
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
                          activityDay,
                        );
                      },
                      child: const Icon(AbiliaIcons.handiUncheck),
                    ),
                  if (displayAlarmButton)
                    ActionButtonLight(
                      key: TestKey.editAlarm,
                      onPressed: () => _alarmButtonPressed(
                        context,
                        activityDay,
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
                      activityDay: activityDay,
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
    ActivityDay activityDay,
  ) async {
    final activity = activityDay.activity;
    final result = await Navigator.of(context).push<Activity>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: BlocProvider<EditActivityCubit>(
            create: (_) => EditActivityCubit.edit(activityDay),
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
              activityDay.day,
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
            activityDay,
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
    required this.activityDay,
    required this.settings,
  }) : super(key: key);

  final ActivityDay activityDay;
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
                  BlocProvider<EditActivityCubit>(
                    create: (_) => EditActivityCubit.edit(activityDay),
                  ),
                  BlocProvider(
                    create: (context) => ActivityWizardCubit.edit(
                      activitiesBloc: context.read<ActivitiesBloc>(),
                      editActivityCubit: context.read<EditActivityCubit>(),
                      clockBloc: context.read<ClockBloc>(),
                      settings: settings,
                    ),
                  ),
                ],
                child: const ActivityWizardPage(),
              ),
            ),
            settings: RouteSettings(name: '$ActivityWizardPage $activityDay'),
          ),
        );
      },
      child: const Icon(AbiliaIcons.edit),
    );
  }
}
