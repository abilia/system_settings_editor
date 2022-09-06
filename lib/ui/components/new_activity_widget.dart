import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/calendar_db.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class NewActivityWidget extends StatelessWidget {
  const NewActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    final addActivitySettings = context.select(
        (MemoplannerSettingBloc bloc) => bloc.state.settings.addActivity);
    return Column(
      children: [
        if (addActivitySettings.newActivityOption)
          PickField(
            key: TestKey.newActivityChoice,
            leading: const Icon(AbiliaIcons.basicActivity),
            text: Text(t.newActivity),
            onTap: () => navigateToActivityWizardWithContext(
              context,
              authProviders,
            ),
          ).pad(layout.templates.m1.withoutBottom),
        if (addActivitySettings.basicActivityOption)
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
      ],
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
