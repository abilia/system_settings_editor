import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class NewTimerWidget extends StatelessWidget {
  const NewTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final t = Translator.of(context).translate;
    return Column(
      children: [
        PickField(
          key: TestKey.newTimerChoice,
          leading: const Icon(AbiliaIcons.stopWatch),
          text: Text(t.newTimer),
          onTap: () => _navigateToEditTimerPage(context, authProviders),
        ).pad(layout.templates.m1.withoutBottom),
        PickField(
          key: TestKey.basicTimerChoice,
          leading: const Icon(AbiliaIcons.basicTimers),
          text: Text(t.fromTemplate),
          onTap: () => _navigateToBasicTimerPage(context, authProviders),
        ).pad(m1ItemPadding),
      ],
    );
  }

  Future<void> _navigateToBasicTimerPage(
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

  Future<void> _navigateToEditTimerPage(
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
      ),
    );
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
