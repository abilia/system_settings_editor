import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'all.dart';

class SimpleBlocDelegate extends BlocDelegate {
  static final _log = Logger((SimpleBlocDelegate).toString());
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (event is! Silent) {
      _log.fine(event);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    super.onTransition(bloc, transition);
    await logEventToAnalytics(transition);
    if (transition.event is! Silent) {
      _log.fine(transition);
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    _log.fine('$bloc $error $stacktrace');
  }

  void logEventToAnalytics(Transition transition) async {
    final event = transition.event;
    final nextState = transition.nextState;
    if (event is AddActivity) {
      await AnalyticsService.sendActivityCreatedEvent(event.activity);
    } else if (event is LoggedIn) {
      await AnalyticsService.sendLoginEvent();
    }
    if (nextState is Authenticated) {
      await AnalyticsService.setUserId(nextState.userId);
    }
  }
}
