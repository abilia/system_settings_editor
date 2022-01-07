import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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
            formTopSpacer,
            if (memoplannerSettingsState.newActivityOption)
              PickField(
                key: TestKey.newActivityChoice,
                leading: const Icon(AbiliaIcons.basicActivity),
                text: Text(t.newActivity),
                onTap: () => navigateToActivityWizard(context, authProviders),
              ).pad(formItemPadding),
            if (memoplannerSettingsState.basicActivityOption)
              PickField(
                key: TestKey.basicActivityChoice,
                leading: const Icon(AbiliaIcons.folder),
                text: Text(t.basicActivities),
                onTap: () async {
                  final basicActivityData =
                      await Navigator.of(context).push<BasicActivityData>(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: BlocProvider<
                            SortableArchiveBloc<BasicActivityData>>(
                          create: (_) => SortableArchiveBloc<BasicActivityData>(
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
              ).pad(formItemPadding),
            const Divider().pad(EdgeInsets.only(top: 16.s)),
            PickField(
              key: TestKey.newTimerChoice,
              leading: const Icon(AbiliaIcons.stopWatch),
              text: Text(t.newTimer),
              onTap: () async {
                final timerStarted = await Navigator.of(context).push(
                  _createRoute(
                    MultiBlocProvider(
                      providers: authProviders,
                      child: BlocProvider(
                        create: (context) => TimerWizardCubit(
                          timerCubit: context.read<TimerCubit>(),
                          translate: t,
                        ),
                        child: const TimerWizardPage(),
                      ),
                    ),
                  ),
                );
                if (timerStarted == true) Navigator.pop(context);
              },
            ).pad(topPadding),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(
          backNavigationWidget: CancelButton(),
        ),
      ),
    );
  }

  Future navigateToActivityWizard(
      BuildContext context, List<BlocProvider> authProviders,
      [BasicActivityDataItem? basicActivity]) async {
    final activityCreated = await Navigator.of(context).push<bool>(
      _createRoute(
        MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityBloc>(
              create: (context) => EditActivityBloc.newActivity(
                day: context.read<DayPickerBloc>().state.day,
                defaultAlarmTypeSetting: context
                    .read<MemoplannerSettingBloc>()
                    .state
                    .defaultAlarmTypeSetting,
                basicActivityData: basicActivity,
              ),
            ),
            BlocProvider(
              create: (context) => ActivityWizardCubit.newActivity(
                activitiesBloc: context.read<ActivitiesBloc>(),
                editActivityBloc: context.read<EditActivityBloc>(),
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

  Route<bool> _createRoute(Widget page) => PageRouteBuilder<bool>(
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
