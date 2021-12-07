import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.plus,
        title: t.add,
      ),
      body: Column(
        children: [
          PickField(
            leading: const Icon(AbiliaIcons.basicActivity),
            text: Text(t.newActivity),
            onTap: () {
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
                          ),
                        ),
                        BlocProvider(
                          create: (context) => ActivityWizardCubit.newActivity(
                            activitiesBloc: context.read<ActivitiesBloc>(),
                            editActivityBloc: context.read<EditActivityBloc>(),
                            clockBloc: context.read<ClockBloc>(),
                            settings:
                                context.read<MemoplannerSettingBloc>().state,
                          ),
                        ),
                      ],
                      child: const ActivityWizardPage(),
                    ),
                  ),
                ),
              );
            },
          ).pad(const EdgeInsets.all(20)),
          PickField(
            leading: const Icon(AbiliaIcons.folder),
            text: Text(t.basicActivities),
            onTap: () {},
          ).pad(const EdgeInsets.all(20)),
          const Divider(),
          PickField(
            leading: const Icon(AbiliaIcons.stopWatch),
            text: const Text('New timer'),
            onTap: () {
              Navigator.of(context).push(
                _createRoute(
                  CopiedAuthProviders(
                    blocContext: context,
                    child: BlocProvider(
                      create: (context) => TimerWizardCubit(),
                      child: const TimerWizardPage(),
                    ),
                  ),
                ),
              );
            },
          ).pad(const EdgeInsets.all(20)),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
