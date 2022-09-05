import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({
    Key? key,
    this.showActivities = true,
    this.showTimers = true,
  })  : assert(showActivities || showTimers),
        assert(!Config.isMPGO || (showActivities && showTimers)),
        super(key: key);

  final bool showActivities, showTimers;

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    final displaysSettings = context.select(
        (MemoplannerSettingBloc bloc) => bloc.state.settings.functions.display);
    final addActivitySettings = context.select(
        (MemoplannerSettingBloc bloc) => bloc.state.settings.addActivity);
    final displayNewActivity = displaysSettings.newActivity && showActivities;
    final displayNewTimer = displaysSettings.newTimer && showTimers;

    return Scaffold(
      appBar: _appBar(t, displayNewActivity, displayNewTimer),
      body: Column(
        children: [
          if (addActivitySettings.newActivityOption && displayNewActivity)
            PickField(
              key: TestKey.newActivityChoice,
              leading: const Icon(AbiliaIcons.basicActivity),
              text: Text(t.newActivity),
              onTap: () => navigateToActivityWizardWithContext(
                context,
                authProviders,
              ),
            ).pad(layout.templates.m1.withoutBottom),
          if (addActivitySettings.basicActivityOption && displayNewActivity)
            PickField(
              key: TestKey.basicActivityChoice,
              leading: const Icon(AbiliaIcons.basicActivities),
              text: Text(t.fromTemplate),
              onTap: () => navigateToBasicActivityPicker(
                context,
                authProviders,
                addActivitySettings.defaults,
              ),
            ).pad(m1ItemPadding),
          if (displayNewActivity && displayNewTimer)
            const Divider().pad(
              EdgeInsets.only(
                top: layout.formPadding.groupBottomDistance,
              ),
            ),
          if (displayNewTimer)
            PickField(
              key: TestKey.newTimerChoice,
              leading: const Icon(AbiliaIcons.stopWatch),
              text: Text(t.newTimer),
              onTap: () => navigateToEditTimerPage(context, authProviders),
            ).pad(layout.templates.m1.withoutBottom),
          if (displayNewTimer)
            PickField(
              key: TestKey.basicTimerChoice,
              leading: const Icon(AbiliaIcons.basicTimers),
              text: Text(t.fromTemplate),
              onTap: () async {
                final navigator = Navigator.of(context);
                final timerStarted = await navigator.push<AbiliaTimer>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        ...authProviders,
                        BlocProvider<SortableArchiveCubit<BasicTimerData>>(
                          create: (_) => SortableArchiveCubit<BasicTimerData>(
                            sortableBloc:
                                BlocProvider.of<SortableBloc>(context),
                          ),
                        ),
                        BlocProvider<EditTimerCubit>(
                          create: (_) => EditTimerCubit(
                            timerCubit: context.read<TimerCubit>(),
                            translate: t,
                            ticker: GetIt.I<Ticker>(),
                          ),
                        ),
                      ],
                      child: const BasicTimerPickerPage(),
                    ),
                  ),
                );
                if (timerStarted != null) {
                  navigateToTimerPage(
                    navigator,
                    authProviders,
                    timerStarted,
                  );
                }
              },
            ).pad(m1ItemPadding),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }

  AbiliaAppBar _appBar(
    Translated t,
    bool displayNewActivity,
    bool displayNewTimer,
  ) {
    return AbiliaAppBar(
      iconData: Config.isMPGO || displayNewActivity
          ? AbiliaIcons.plus
          : AbiliaIcons.stopWatch,
      title: Config.isMPGO || displayNewTimer && displayNewActivity
          ? t.add
          : displayNewActivity
              ? t.addActivity
              : t.addTimer,
    );
  }

  Future<void> navigateToEditTimerPage(
      BuildContext buildContext, List<BlocProvider> authProviders,
      [BasicTimerDataItem? basicTimer]) async {
    final navigator = Navigator.of(buildContext);
    final timerStarted = await Navigator.of(buildContext).push(
      _createRoute<AbiliaTimer>(
        MultiBlocProvider(
          providers: authProviders,
          child: BlocProvider(
            create: (context) => EditTimerCubit(
              timerCubit: context.read<TimerCubit>(),
              translate: Translator.of(buildContext).translate,
              ticker: GetIt.I<Ticker>(),
              basicTimer: basicTimer,
            ),
            child: const EditTimerPage(),
          ),
        ),
      ),
    );
    if (timerStarted != null) {
      navigateToTimerPage(
        navigator,
        authProviders,
        timerStarted,
      );
    }
  }

  void navigateToTimerPage(
    NavigatorState navigator,
    List<BlocProvider> authProviders,
    AbiliaTimer timer,
  ) {
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: authProviders,
          child: TimerPage(
            timerOccasion: TimerOccasion(timer, Occasion.current),
            day: timer.startTime.onlyDays(),
          ),
        ),
      ),
    );
  }

  static Future<void> navigateToBasicActivityPicker(
    BuildContext context,
    List<BlocProvider> authProviders,
    DefaultsAddActivitySettings defaultsSettings,
  ) async {
    final navigator = Navigator.of(context);
    final day = context.read<DayPickerBloc>().state.day;
    final basicActivityData =
        await Navigator.of(context).push<BasicActivityData>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: BlocProvider<SortableArchiveCubit<BasicActivityData>>(
            create: (_) => SortableArchiveCubit<BasicActivityData>(
              sortableBloc: BlocProvider.of<SortableBloc>(context),
            ),
            child: const BasicActivityPickerPage(),
          ),
        ),
      ),
    );
    if (basicActivityData is BasicActivityDataItem) {
      _navigateToActivityWizard(
        authProviders: authProviders,
        navigator: navigator,
        defaultsSettings: defaultsSettings,
        day: day,
        basicActivity: basicActivityData,
      );
    }
  }

  static Future<void> navigateToActivityWizardWithContext(
    BuildContext context,
    List<BlocProvider> authProviders,
  ) =>
      _navigateToActivityWizard(
        authProviders: authProviders,
        navigator: Navigator.of(context),
        defaultsSettings: context
            .read<MemoplannerSettingBloc>()
            .state
            .settings
            .addActivity
            .defaults,
        day: context.read<DayPickerBloc>().state.day,
      );

  static Future<void> _navigateToActivityWizard({
    required NavigatorState navigator,
    required DateTime day,
    required DefaultsAddActivitySettings defaultsSettings,
    required List<BlocProvider> authProviders,
    BasicActivityDataItem? basicActivity,
  }) async {
    final calendarId = await GetIt.I<CalendarDb>().getCalendarId() ?? '';
    final activityCreated = await navigator.push<bool>(
      _createRoute<bool>(
        MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityCubit>(
              create: (_) => EditActivityCubit.newActivity(
                day: day,
                calendarId: calendarId,
                defaultsSettings: defaultsSettings,
                basicActivityData: basicActivity,
              ),
            ),
            BlocProvider<WizardCubit>(
              create: (context) {
                final settings = context
                    .read<MemoplannerSettingBloc>()
                    .state
                    .settings
                    .addActivity;
                return settings.mode == AddActivityMode.editView
                    ? ActivityWizardCubit.newAdvanced(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        clockBloc: context.read<ClockBloc>(),
                        allowPassedStartTime:
                            settings.general.allowPassedStartTime,
                      )
                    : ActivityWizardCubit.newStepByStep(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        clockBloc: context.read<ClockBloc>(),
                        allowPassedStartTime:
                            settings.general.allowPassedStartTime,
                        stepByStep: settings.stepByStep,
                        addRecurringActivity:
                            settings.general.addRecurringActivity,
                      );
              },
            ),
          ],
          child: const ActivityWizardPage(),
        ),
      ),
    );
    if (activityCreated == true) navigator.pop();
  }

  static Route<T> _createRoute<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
              CurveTween(curve: Curves.ease),
            ),
          ),
          child: child,
        ),
      );
}
