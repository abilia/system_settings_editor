import 'package:calendar/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:sortables/sortables.dart';

mixin ActivityNavigation {
  Future<void> navigateToBasicActivityPicker(
    BuildContext context,
    List<BlocProvider> authProviders,
    DefaultsAddActivitySettings defaultsSettings,
  ) async {
    final day = context.read<DayPickerBloc>().state.day;
    final calendarId = context.read<CalendarCubit>().state;
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
        settings: (BasicActivityPickerPage).routeSetting(),
      ),
    );
    if (basicActivityData is BasicActivityDataItem && context.mounted) {
      await _navigateToActivityWizard(
        authProviders: authProviders,
        context: context,
        defaultsSettings: defaultsSettings,
        day: day,
        calendarId: calendarId ?? '',
        basicActivity: basicActivityData,
      );
    }
  }

  Future<void> navigateToActivityWizardWithContext(
    BuildContext context,
    List<BlocProvider> authProviders, {
    BasicActivityDataItem? basicActivity,
    AddActivityMode? addActivityMode,
  }) {
    final settings = context.read<MemoplannerSettingsBloc>().state;
    final calendarId = context.read<CalendarCubit>().state;
    final defaultsSettings = settings.addActivity.defaults;
    return _navigateToActivityWizard(
      authProviders: authProviders,
      context: context,
      defaultsSettings: defaultsSettings,
      calendarId: calendarId ?? '',
      day: context.read<DayPickerBloc>().state.day,
      basicActivity: basicActivity,
      addActivityMode: addActivityMode,
    );
  }

  Future<void> _navigateToActivityWizard({
    required BuildContext context,
    required DateTime day,
    required DefaultsAddActivitySettings defaultsSettings,
    required List<BlocProvider> authProviders,
    required String calendarId,
    BasicActivityDataItem? basicActivity,
    AddActivityMode? addActivityMode,
  }) async {
    final activityCreated = await Navigator.of(context).push<bool>(
      createSlideRoute<bool>(
        settings: (ActivityWizardPage).routeSetting(),
        page: MultiBlocProvider(
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
                final settings = context.read<MemoplannerSettingsBloc>().state;
                final addActivitySettings = settings.addActivity;
                final showCategories = settings.calendar.categories.show;
                final supportPersonsCubit = context.read<SupportPersonsCubit>()
                  ..loadSupportPersons();
                addActivityMode ??= addActivitySettings.mode;
                return addActivityMode == AddActivityMode.editView
                    ? ActivityWizardCubit.newAdvanced(
                        activitiesCubit: context.read<ActivitiesCubit>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        clockCubit: context.read<ClockCubit>(),
                        allowPassedStartTime:
                            addActivitySettings.general.allowPassedStartTime,
                      )
                    : ActivityWizardCubit.newStepByStep(
                        activitiesCubit: context.read<ActivitiesCubit>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        supportPersonsCubit: supportPersonsCubit,
                        clockCubit: context.read<ClockCubit>(),
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
    if (activityCreated == true && context.mounted) {
      await Navigator.of(context).maybePop();
    }
  }
}

Route<T> createSlideRoute<T>({
  required RouteSettings settings,
  required Widget page,
}) =>
    PersistentPageRouteBuilder<T>(
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
      settings: settings,
    );
