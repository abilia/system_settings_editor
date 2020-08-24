import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:logging/logging.dart';
import 'package:bloc/bloc.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';

void initLogging({bool initAppcenter = false, Level level = Level.ALL}) async {
  if (initAppcenter) {
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
    final appId = 'e0cb99ae-de4a-4bf6-bc91-ccd7d843f5ed';
    await AppCenter.startAsync(
      appSecretAndroid: appId,
      appSecretIOS: appId,
    );
    await AppCenter.configureDistributeDebugAsync(enabled: false);
  }

  Bloc.observer = BlocLoggingObserver();

  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record?.error != null) {
      print(record.error);
    }
    if (record?.stackTrace != null) {
      print(record.stackTrace);
    }
  });
}

mixin Silent {}
mixin Finest {}
mixin Finer implements Finest {}
mixin Fine implements Finer {}
mixin Info implements Fine {}
mixin Warning implements Info {}
mixin Shout implements Warning {}

class BlocLoggingObserver extends BlocObserver {
  final _loggers = <Bloc, Logger>{};
  Logger _log(Bloc bloc) =>
      _loggers[bloc] ??= Logger(bloc.runtimeType.toString());
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (event is Silent || bloc is Silent) return;
    final log = _log(bloc);
    if (event is Shout) {
      log.shout(event);
    } else if (event is Warning) {
      log.warning(event);
    } else if (event is Info) {
      log.info(event);
    } else if (event is Fine) {
      log.fine(event);
    } else if (event is Finest) {
      log.finest(event);
    } else {
      log.finer(event);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    super.onTransition(bloc, transition);
    await logEventToAnalytics(transition);
    final event = transition.event;
    if (event is Silent || bloc is Silent) return;
    final log = _log(bloc);
    if (event is! Silent) {
      if (event is Shout) {
        log.shout(transition);
      } else if (event is Warning) {
        log.warning(transition);
      } else if (event is Info) {
        log.info(transition);
      } else if (event is Fine) {
        log.fine(transition);
      } else if (event is Finer) {
        log.finer(transition);
      } else {
        log.finest(transition);
      }
    }
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stacktrace) {
    super.onError(cubit, error, stacktrace);
    _log(cubit).severe('error in $cubit', error, stacktrace);
  }

  void logEventToAnalytics(Transition transition) async {
    final event = transition.event;
    final nextState = transition.nextState;
    if (event is AddActivity) {
      await AnalyticsService.sendActivityCreatedEvent(event.activity);
    }
    if (event is LoggedIn) {
      await AnalyticsService.sendLoginEvent();
    }
    if (nextState is Authenticated) {
      await AnalyticsService.setUserId(nextState.userId);
    }
  }
}

class RouteLoggingObserver extends RouteObserver<PageRoute<dynamic>> {
  final _log = Logger('RouteLogger');

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _log.fine('didPush $route');
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _log.fine('didReplace $newRoute');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _log.fine('didPop $route');
    }
  }
}
