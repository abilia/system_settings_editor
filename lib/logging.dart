import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:logging/logging.dart';
import 'package:bloc/bloc.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';

void initLogging() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  final appId = 'e0cb99ae-de4a-4bf6-bc91-ccd7d843f5ed';
  await AppCenter.startAsync(
    appSecretAndroid: appId,
    appSecretIOS: appId,
  );
  await AppCenter.configureDistributeDebugAsync(enabled: false);

  BlocSupervisor.delegate = BlocLoggingDelegate();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.level == Level.SEVERE) {
      print(record.error);
      print(record.stackTrace);
    }
  });
}

mixin Silent {}
mixin Finer {}
mixin Fine implements Finer {}
mixin Info implements Fine {}
mixin Warning implements Info {}
mixin Shout implements Warning {}

class BlocLoggingDelegate extends BlocDelegate {
  static final _log = Logger((BlocLoggingDelegate).toString());
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (event is! Silent) {
      if (event is Shout) {
        _log.shout(event);
      } else if (event is Warning) {
        _log.warning(event);
      } else if (event is Info) {
        _log.info(event);
      } else if (event is Fine) {
        _log.fine(event);
      } else if (event is Finer) {
        _log.finer(event);
      } else {
        _log.finest(event);
      }
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    super.onTransition(bloc, transition);
    await logEventToAnalytics(transition);
    final event = transition.event;
    if (transition.event is! Silent) {
      if (event is! Silent) {
        if (event is Shout) {
          _log.shout(transition);
        } else if (event is Warning) {
          _log.warning(transition);
        } else if (event is Info) {
          _log.info(transition);
        } else if (event is Fine) {
          _log.fine(transition);
        } else if (event is Finer) {
          _log.finer(transition);
        } else {
          _log.finest(transition);
        }
      }
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    _log.severe('error in bloc $bloc', error, stacktrace);
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
