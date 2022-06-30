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
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocProvider<ActivityCubit>(
        create: (context) => ActivityCubit(
          ad: activityDay,
          activitiesBloc: context.read<ActivitiesBloc>(),
        ),
        child: BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) {
            final ad = state.activityDay;
            return Scaffold(
              appBar: DayAppBar(
                day: ad.day,
              ),
              body: ActivityInfoWithDots(
                ad,
                previewImage: previewImage,
              ),
              bottomNavigationBar: _ActivityBottomAppBar(activityDay: ad),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityBottomAppBar extends StatelessWidget with ActivityMixin {
  const _ActivityBottomAppBar({
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
        final noButtons = [
          displayDeleteButton,
          displayEditButton,
          displayAlarmButton,
          displayUncheckButton,
        ].isEmpty;

        if (noButtons) return const SizedBox.shrink();

        final t = Translator.of(context).translate;
        return BottomAppBar(
          child: SizedBox(
            height: layout.toolbar.height,
            child: Row(
              children: <Widget>[
                if (displayUncheckButton)
                  TextAndOrIconActionButtonLight(
                    t.undo,
                    AbiliaIcons.handiUncheck,
                    key: TestKey.uncheckButton,
                    onPressed: () async {
                      await checkConfirmation(
                        context,
                        activityDay,
                      );
                    },
                  ),
                if (displayAlarmButton)
                  TextAndOrIconActionButtonLight(
                    t.alarm,
                    activity.alarm.iconData(),
                    key: TestKey.editAlarm,
                    onPressed: () => _alarmButtonPressed(
                      context,
                      activityDay,
                    ),
                  ),
                if (displayDeleteButton)
                  TextAndOrIconActionButtonLight(
                    t.delete,
                    AbiliaIcons.deleteAllClear,
                    onPressed: () => _deleteButtonPressed(
                      context,
                      activity,
                    ),
                  ),
                if (displayEditButton)
                  EditActivityButton(activityDay: activityDay),
                TextAndOrIconActionButtonLight(
                  Translator.of(context).translate.close,
                  AbiliaIcons.navigationPrevious,
                  key: TestKey.activityBackButton,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ]
                  .map((b) => [const Spacer(), b, const Spacer()])
                  .expand((w) => w)
                  .toList(),
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
    final authProviders = copiedAuthProviders(context);
    final navigator = Navigator.of(context);
    final activitiesBloc = context.read<ActivitiesBloc>();
    final result = await Navigator.of(context).push<Activity>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: BlocProvider<EditActivityCubit>(
            create: (_) => EditActivityCubit.edit(activityDay),
            child: SelectAlarmPage(activity: activity),
          ),
        ),
        settings: const RouteSettings(name: 'SelectAlarmPage'),
      ),
    );

    if (result != null) {
      if (activity.isNoneSingleInstanceRecurring) {
        final applyTo = await navigator.push<ApplyTo>(
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
    final activitiesBloc = context.read<ActivitiesBloc>();
    final navigator = Navigator.of(context);
    final shouldDelete = await showViewDialog<bool>(
      context: context,
      builder: (_) => YesNoDialog(
        heading: Translator.of(context).translate.delete,
        headingIcon: AbiliaIcons.deleteAllClear,
        text: Translator.of(context).translate.deleteActivity,
      ),
    );
    if (shouldDelete == true) {
      if (activity.isNoneSingleInstanceRecurring) {
        final applyTo = await navigator.push<ApplyTo>(
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
      await navigator.maybePop();
    }
  }
}

class EditActivityButton extends StatelessWidget {
  const EditActivityButton({
    Key? key,
    required this.activityDay,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) => TextAndOrIconActionButtonLight(
        Translator.of(context).translate.edit,
        AbiliaIcons.edit,
        onPressed: () {
          final authProviders = copiedAuthProviders(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  ...authProviders,
                  BlocProvider<EditActivityCubit>(
                    create: (_) => EditActivityCubit.edit(activityDay),
                  ),
                  BlocProvider<WizardCubit>(
                    create: (context) => ActivityWizardCubit.edit(
                      activitiesBloc: context.read<ActivitiesBloc>(),
                      editActivityCubit: context.read<EditActivityCubit>(),
                      clockBloc: context.read<ClockBloc>(),
                      allowPassedStartTime: context
                          .read<MemoplannerSettingBloc>()
                          .state
                          .settings
                          .addActivity
                          .allowPassedStartTime,
                    ),
                  ),
                ],
                child: const ActivityWizardPage(),
              ),
              settings: RouteSettings(name: '$ActivityWizardPage $activityDay'),
            ),
          );
        },
      );
}
