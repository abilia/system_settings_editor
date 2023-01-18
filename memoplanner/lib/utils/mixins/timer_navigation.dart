import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

mixin TimerNavigation {
  Future<void> navigateToBasicTimerPage(
      BuildContext context, List<BlocProvider> authProviders) async {
    final navigator = Navigator.of(context);
    final timerStarted = await navigator.push<AbiliaTimer>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<SortableArchiveCubit<BasicTimerData>>(
              create: (_) => SortableArchiveCubit<BasicTimerData>(
                sortableBloc: BlocProvider.of<SortableBloc>(context),
              ),
            ),
            BlocProvider<EditTimerCubit>(
              create: (_) => EditTimerCubit(
                timerCubit: context.read<TimerCubit>(),
                translate: Translator.of(context).translate,
                ticker: GetIt.I<Ticker>(),
              ),
            ),
          ],
          child: const BasicTimerPickerPage(),
        ),
        settings: (BasicTimerPickerPage).routeSetting(),
      ),
    );
    if (timerStarted != null) {
      _navigateToTimerPage(
        navigator,
        authProviders,
        timerStarted,
      );
    }
  }

  Future<void> navigateToEditTimerPage(
      BuildContext buildContext, List<BlocProvider> authProviders,
      [BasicTimerDataItem? basicTimer]) async {
    final navigator = Navigator.of(buildContext);
    final timerStarted = await Navigator.of(buildContext).push(
      createSlideRoute<AbiliaTimer>(
        settings: (EditTimerPage).routeSetting(),
        page: MultiBlocProvider(
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
      _navigateToTimerPage(
        navigator,
        authProviders,
        timerStarted,
      );
    }
  }

  void _navigateToTimerPage(
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
        settings: (TimerPage).routeSetting(),
      ),
    );
  }
}
