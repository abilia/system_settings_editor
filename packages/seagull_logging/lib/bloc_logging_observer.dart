import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_logging/seagull_logging.dart';

class BlocLoggingObserver extends BlocObserver {
  BlocLoggingObserver(
    this.analytics, {
    required this.isRelease,
  });

  final SeagullAnalytics analytics;
  final bool isRelease;
  final _loggers = <BlocBase, Logger>{};

  Logger _getLog(BlocBase bloc) =>
      _loggers[bloc] ??= Logger(bloc.runtimeType.toString());

  void _log(BlocBase bloc, Object? message) {
    if (bloc is Silent) return;
    final log = _getLog(bloc);
    if (bloc is Shout) {
      log.shout(message);
    } else if (bloc is Warning) {
      log.warning(message);
    } else if (bloc is Info) {
      log.info(message);
    } else if (bloc is Fine) {
      log.fine(message);
    } else if (bloc is Finest) {
      log.finest(message);
    } else {
      log.finer(message);
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (bloc is Silent) return;
    _log(bloc, 'created ${bloc.state}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is Silent || bloc is Silent) return;
    _log(bloc, 'event $event');
  }

  @override
  Future<void> onChange(BlocBase bloc, Change change) async {
    super.onChange(bloc, change);
    if (bloc is Silent) return;
    await onChangeAnalytics(bloc, change);
    _log(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (bloc is Silent) return;
    onTransitionAnalytics(transition);
    _log(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _getLog(bloc).severe(error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (bloc is Silent) return;
    _log(bloc, 'closed');
  }

  void onTransitionAnalytics(Transition transition) {
    final nextState = transition.nextState;
    final currentState = transition.currentState;
    if (nextState is Authenticated) {
      final user = nextState.user;
      analytics.setSuperProperties(
        {
          AnalyticsProperties.userType: user.type,
          AnalyticsProperties.userLang: user.language,
        },
      );
    }
    if (currentState is Authenticated && nextState is Unauthenticated) {
      analytics.reset();
    }
  }

  Future<void> onChangeAnalytics(BlocBase bloc, Change change) async {
    if (bloc is BaseUrlCubit && change is Change<String>) {
      await _backendChanged(change);
    }
  }

  Future<void> _backendChanged(Change<String> change) async {
    analytics.setBackend(backendName(change.nextState));
    if (isRelease) return;
    if (change.nextState == prod) {
      // Changed from sandbox to prod
      await analytics.changeMixpanelProject(MixpanelProject.memoProd);
    } else if (change.currentState == prod) {
      // Changed from prod to sandbox
      await analytics.changeMixpanelProject(MixpanelProject.sandbox);
    }
  }
}
