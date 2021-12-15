import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onTap: () async {
                  await Navigator.of(context).maybePop();
                  navigateToActivityWizard(context);
                },
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
                      builder: (_) => CopiedAuthProviders(
                        blocContext: context,
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
                    await Navigator.of(context).maybePop();
                    navigateToActivityWizard(context, basicActivityData);
                  }
                },
              ).pad(formItemPadding),
            const Divider().pad(const EdgeInsets.only(top: 16)),
            PickField(
              leading: const Icon(AbiliaIcons.stopWatch),
              text: Text(t.newTimer),
              onTap: () async {
                await Navigator.of(context).maybePop();
                Navigator.of(context).push(
                  _createRoute(
                    CopiedAuthProviders(
                      blocContext: context,
                      child: BlocProvider(
                        create: (context) => TimerWizardCubit(
                          timerCubit: context.read<TimerCubit>(),
                          onBack: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CopiedAuthProviders(
                                  blocContext: context,
                                  child: const CreateNewPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        child: const TimerWizardPage(),
                      ),
                    ),
                  ),
                );
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

  void navigateToActivityWizard(BuildContext context,
      [BasicActivityDataItem? basicActivity]) {
    Navigator.of(context).push(
      _createRoute(
        CopiedAuthProviders(
          blocContext: context,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<EditActivityBloc>(
                create: (_) => EditActivityBloc.newActivity(
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
                    onBack: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CopiedAuthProviders(
                            blocContext: context,
                            child: const CreateNewPage(),
                          ),
                        ),
                      );
                    }),
              ),
            ],
            child: const ActivityWizardPage(),
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
