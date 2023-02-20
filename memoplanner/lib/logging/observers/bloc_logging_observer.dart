import 'dart:ui';

import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/end_point.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class BlocLoggingObserver extends BlocObserver {
  BlocLoggingObserver(this.analytics);

  final SeagullAnalytics analytics;
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
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Silent) return;
    onChangeAnalytics(bloc, change);
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
    final event = transition.event;
    final nextState = transition.nextState;
    final currentState = transition.currentState;
    if (event is TrackableEvent) {
      analytics.trackEvent(event.eventName, properties: event.properties);
    }
    if (nextState is Authenticated) {
      final user = nextState.user;
      analytics.identifyAndRegisterSuperProperties(
        identifier: user.id.toString(),
        superProperties: {
          'user_type': user.type,
          'user_language': user.language,
        },
      );
    }
    if (currentState is Authenticated && nextState is Unauthenticated) {
      analytics.reset();
    }
  }

  void onChangeAnalytics(BlocBase bloc, Change change) {
    final nextState = change.nextState;
    if (bloc is BaseUrlCubit && nextState is String) {
      analytics.setBackend(backendName(nextState));
    }
    if (bloc is LocaleCubit && nextState is Locale) {
      analytics.setLocale(nextState);
    }
  }
}