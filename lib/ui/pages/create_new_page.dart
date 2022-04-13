import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoplannerSettingsState) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.plus,
          title: t.add,
        ),
        body: Column(
          children: [
            SizedBox(height: layout.templates.m1.top),
            if (memoplannerSettingsState.newActivityOption)
              PickField(
                key: TestKey.newActivityChoice,
                leading: const Icon(AbiliaIcons.basicActivity),
                text: Text(t.newActivity),
                onTap: () => navigateToActivityWizard(context, authProviders),
              ).pad(m1ItemPadding),
            if (memoplannerSettingsState.basicActivityOption)
              PickField(
                key: TestKey.basicActivityChoice,
                leading: const Icon(AbiliaIcons.folder),
                text: Text(t.selectBasicActivity),
                onTap: () async {
                  final basicActivityData =
                      await Navigator.of(context).push<BasicActivityData>(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: BlocProvider<
                            SortableArchiveCubit<BasicActivityData>>(
                          create: (_) =>
                              SortableArchiveCubit<BasicActivityData>(
                            sortableBloc:
                                BlocProvider.of<SortableBloc>(context),
                          ),
                          child: const BasicActivityPickerPage(),
                        ),
                      ),
                    ),
                  );
                  if (basicActivityData is BasicActivityDataItem) {
                    await navigateToActivityWizard(
                      context,
                      authProviders,
                      basicActivityData,
                    );
                  }
                },
              ).pad(m1ItemPadding),
            const Divider().pad(EdgeInsets.only(
              top: layout.formPadding.groupBottomDistance,
            )),
            PickField(
              key: TestKey.newTimerChoice,
              leading: const Icon(AbiliaIcons.stopWatch),
              text: Text(t.newTimer),
              onTap: () async {
                navigateToTimerWizard(context, authProviders);
              },
            ).pad(m1WithZeroBottom),
            PickField(
              key: TestKey.basicTimerChoice,
              leading: const Icon(AbiliaIcons.folder),
              text: Text(t.selectBaseTimer),
              onTap: () async {
                final basicTimerData =
                    await Navigator.of(context).push<BasicTimerData>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: BlocProvider<SortableArchiveCubit<BasicTimerData>>(
                        create: (_) => SortableArchiveCubit<BasicTimerData>(
                          sortableBloc: BlocProvider.of<SortableBloc>(context),
                        ),
                        child: const BasicTimerPickerPage(),
                      ),
                    ),
                  ),
                );
                if (basicTimerData is BasicTimerDataItem) {
                  await navigateToTimerWizard(
                    context,
                    authProviders,
                    basicTimerData,
                  );
                }
              },
            ).pad(m1ItemPadding),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(
          backNavigationWidget: CancelButton(),
        ),
      ),
    );
  }

  Future<void> navigateToTimerWizard(
      BuildContext buildContext, List<BlocProvider> authProviders,
      [BasicTimerDataItem? basicTimer]) async {
    final timerStarted = await Navigator.of(buildContext).push(
      _createRoute<AbiliaTimer>(
        MultiBlocProvider(
          providers: authProviders,
          child: BlocProvider(
            create: (context) => TimerWizardCubit(
              timerCubit: context.read<TimerCubit>(),
              translate: Translator.of(buildContext).translate,
              ticker: GetIt.I<Ticker>(),
              basicTimer: basicTimer,
            ),
            child: const TimerWizardPage(),
          ),
        ),
      ),
    );
    if (timerStarted != null) {
      Navigator.of(buildContext).pop();
      final providers = copiedAuthProviders(buildContext);
      Navigator.of(buildContext).push(
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: providers,
            child: TimerPage(
              timerOccasion: TimerOccasion(timerStarted, Occasion.current),
              day: timerStarted.startTime.onlyDays(),
            ),
          ),
        ),
      );
    }
  }

  Future<void> navigateToActivityWizard(
      BuildContext context, List<BlocProvider> authProviders,
      [BasicActivityDataItem? basicActivity]) async {
    final activityCreated = await Navigator.of(context).push<bool>(
      _createRoute<bool>(
        MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityCubit>(
              create: (_) => EditActivityCubit.newActivity(
                day: context.read<DayPickerBloc>().state.day,
                defaultAlarmTypeSetting: context
                    .read<MemoplannerSettingBloc>()
                    .state
                    .defaultAlarmTypeSetting,
                basicActivityData: basicActivity,
              ),
            ),
            BlocProvider<WizardCubit>(
              create: (context) => ActivityWizardCubit.newActivity(
                activitiesBloc: context.read<ActivitiesBloc>(),
                editActivityCubit: context.read<EditActivityCubit>(),
                clockBloc: context.read<ClockBloc>(),
                settings: context.read<MemoplannerSettingBloc>().state,
              ),
            ),
          ],
          child: const ActivityWizardPage(),
        ),
      ),
    );
    if (activityCreated == true) Navigator.pop(context);
  }

  Route<T> _createRoute<T>(Widget page) => PageRouteBuilder<T>(
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
