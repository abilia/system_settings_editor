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
          activitiesBloc: context.read<ActivitiesBloc>(),
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

class _ActivityBottomAppBar extends StatelessWidget with ActivityMixin {
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
            if (displayEditButton) EditActivityButton(activityDay: activityDay),
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
      if (activity.isNoneSingleInstanceRecurring) {
        final applyTo = await navigator.push<ApplyTo>(
          PersistentMaterialPageRoute(
            settings: (SelectRecurrentTypePage).routeSetting(),
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
            startTimeFromActivityDay: true,
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
      builder: (_) => const DeleteActivityDialog(),
      routeSettings: (DeleteActivityDialog).routeSetting(),
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
            settings: (SelectRecurrentTypePage).routeSetting(),
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
        activitiesBloc.add(UpdateActivity(activity.copyWith(deleted: true)));
      }
      await navigator.maybePop();
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
      heading: Translator.of(context).translate.delete,
      headingIcon: AbiliaIcons.deleteAllClear,
      text: Translator.of(context).translate.deleteActivityQuestion,
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
        Translator.of(context).translate.edit,
        AbiliaIcons.edit,
        onPressed: () {
          final authProviders = copiedAuthProviders(context);
          Navigator.of(context).push(
            PersistentMaterialPageRoute(
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
