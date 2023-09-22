import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityPage extends StatelessWidget {
  static PageRoute route({
    required ActivityDay activityDay,
    required List<BlocProvider> authProviders,
  }) =>
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: ActivityPage(activityDay: activityDay),
        ),
        settings: (ActivityPage).routeSetting(),
      );

  final ActivityDay activityDay;
  final Widget? previewImage;

  const ActivityPage({
    required this.activityDay,
    this.previewImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocProvider<ActivityCubit>(
        create: (context) => ActivityCubit(
          activityDay: activityDay,
          activitiesCubit: context.read<ActivitiesCubit>(),
        ),
        child: BlocConsumer<ActivityCubit, ActivityState>(
          listenWhen: (previous, current) => current is ActivityDeleted,
          listener: (context, state) =>
              Navigator.of(context).popUntilActivityRootPage(),
          builder: (context, state) {
            return Scaffold(
              appBar: DayAppBar(
                day: state.activityDay.day,
              ),
              body: ActivityInfoWithDots(
                state.activityDay,
                previewImage: previewImage,
              ),
              bottomNavigationBar:
                  _ActivityBottomAppBar(activityDay: state.activityDay),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityBottomAppBar extends StatelessWidget
    with ActivityAndAlarmsMixin {
  const _ActivityBottomAppBar({
    required this.activityDay,
    Key? key,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final activityViewSettings = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.activityView);
    final displayDeleteButton = activityViewSettings.displayDeleteButton;
    final displayEditButton = activityViewSettings.displayEditButton;
    final displayAlarmButton =
        activityViewSettings.displayAlarmButton && !activity.fullDay;
    final displayUncheckButton = activityDay.isSignedOff;
    final noButtons = [
      displayDeleteButton,
      displayEditButton,
      displayAlarmButton,
      displayUncheckButton,
    ].isEmpty;

    if (noButtons) return const SizedBox.shrink();

    final translate = Lt.of(context);
    return BottomAppBar(
      child: SizedBox(
        height: layout.toolbar.height,
        child: Row(
          children: <Widget>[
            if (displayUncheckButton)
              TextAndOrIconActionButtonLight(
                translate.undo,
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
                translate.alarm,
                activity.alarm.iconData(),
                key: TestKey.editAlarm,
                onPressed: () async => _alarmButtonPressed(
                  context,
                  activityDay,
                ),
              ),
            if (displayDeleteButton)
              TextAndOrIconActionButtonLight(
                translate.delete,
                AbiliaIcons.deleteAllClear,
                onPressed: () async => _deleteButtonPressed(
                  context,
                  activity,
                ),
              ),
            if (displayEditButton) EditActivityButton(activityDay: activityDay),
            TextAndOrIconActionButtonLight(
              Lt.of(context).close,
              AbiliaIcons.navigationPrevious,
              key: TestKey.activityBackButton,
              onPressed: () async => Navigator.of(context).maybePop(),
            ),
          ]
              .map((b) => [const Spacer(), b, const Spacer()])
              .expand((w) => w)
              .toList(),
        ),
      ),
    );
  }

  Future<void> _alarmButtonPressed(
    BuildContext context,
    ActivityDay activityDay,
  ) async {
    final activity = activityDay.activity;
    final authProviders = copiedAuthProviders(context);
    final activitiesCubit = context.read<ActivitiesCubit>();
    final result = await Navigator.of(context).push<Activity>(
      PersistentMaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: BlocProvider<EditActivityCubit>(
            create: (_) => EditActivityCubit.edit(activityDay),
            child: const SelectAlarmPage(),
          ),
        ),
        settings: (SelectAlarmPage).routeSetting(),
      ),
    );

    if (result != null) {
      if (activity.isNoneSingleInstanceRecurring && context.mounted) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          PersistentMaterialPageRoute(
            settings: (SelectRecurrentTypePage).routeSetting(),
            builder: (_) => SelectRecurrentTypePage(
              heading: Lt.of(context).editRecurringActivity,
              headingIcon: AbiliaIcons.edit,
            ),
          ),
        );
        if (applyTo == null) return;
        final withNewStart = result.copyWith(
          startTime: activityDay.day.copyWith(
            hour: activity.startTime.hour,
            minute: activity.startTime.minute,
          ),
        );
        final newActivityDay = ActivityDay(
          withNewStart,
          activityDay.day,
        );
        await activitiesCubit.updateRecurringActivity(newActivityDay, applyTo);
      } else {
        await activitiesCubit.addActivity(result);
      }
    }
  }

  Future<void> _deleteButtonPressed(
    BuildContext context,
    Activity activity,
  ) async {
    final activitiesCubit = context.read<ActivitiesCubit>();
    final shouldDelete = await showViewDialog<bool>(
      context: context,
      builder: (_) => const DeleteActivityDialog(),
      routeSettings: (DeleteActivityDialog).routeSetting(),
    );
    if (shouldDelete == true && context.mounted) {
      if (activity.isNoneSingleInstanceRecurring) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          MaterialPageRoute(
            builder: (_) => SelectRecurrentTypePage(
              heading: Lt.of(context).deleteRecurringActivity,
              allDaysVisible: true,
              headingIcon: AbiliaIcons.deleteAllClear,
            ),
            settings: (SelectRecurrentTypePage).routeSetting(),
          ),
        );
        if (applyTo == null) return;
        await activitiesCubit.deleteRecurringActivity(activityDay, applyTo);
      } else {
        await activitiesCubit.updateActivity(activity.copyWith(deleted: true));
      }
      if (!context.mounted) return;
      await Navigator.of(context).maybePop();
    }
  }
}

class DeleteActivityDialog extends StatelessWidget {
  const DeleteActivityDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YesNoDialog(
      heading: Lt.of(context).delete,
      headingIcon: AbiliaIcons.deleteAllClear,
      text: Lt.of(context).deleteActivityQuestion,
    );
  }
}

class EditActivityButton extends StatelessWidget {
  const EditActivityButton({
    required this.activityDay,
    Key? key,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) => TextAndOrIconActionButtonLight(
        Lt.of(context).edit,
        AbiliaIcons.edit,
        onPressed: () async {
          final authProviders = copiedAuthProviders(context);
          await Navigator.of(context).push(
            PersistentMaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  ...authProviders,
                  BlocProvider<EditActivityCubit>(
                    create: (_) => EditActivityCubit.edit(activityDay),
                  ),
                  BlocProvider<WizardCubit>(
                    create: (context) => ActivityWizardCubit.edit(
                      activitiesCubit: context.read<ActivitiesCubit>(),
                      editActivityCubit: context.read<EditActivityCubit>(),
                      clockCubit: context.read<ClockCubit>(),
                      allowPassedStartTime: context
                          .read<MemoplannerSettingsBloc>()
                          .state
                          .addActivity
                          .general
                          .allowPassedStartTime,
                    ),
                  ),
                ],
                child: const ActivityWizardPage(),
              ),
              settings: (ActivityWizardPage).routeSetting(),
            ),
          );
        },
      );
}
