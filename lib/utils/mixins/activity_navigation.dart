import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

mixin ActivityNavigation {
  Future<void> navigateToBasicActivityPicker(
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

  Future<void> navigateToActivityWizardWithContext(
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

  Future<void> _navigateToActivityWizard({
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
                final settings =
                    context.read<MemoplannerSettingBloc>().state.settings;
                final addActivitySettings = settings.addActivity;
                final showCategories = settings.calendar.categories.show;
                return addActivitySettings.mode == AddActivityMode.editView
                    ? ActivityWizardCubit.newAdvanced(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        clockBloc: context.read<ClockBloc>(),
                        allowPassedStartTime:
                            addActivitySettings.general.allowPassedStartTime,
                      )
                    : ActivityWizardCubit.newStepByStep(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        clockBloc: context.read<ClockBloc>(),
                        allowPassedStartTime:
                            addActivitySettings.general.allowPassedStartTime,
                        stepByStep: addActivitySettings.stepByStep,
                        addRecurringActivity:
                            addActivitySettings.general.addRecurringActivity,
                        showCategories: showCategories,
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
