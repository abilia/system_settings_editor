import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:bloc/bloc.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'db/all.dart';

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

  if (kReleaseMode) {
    await initFileLogging(level);
  } else {
    initPrintLogging(level);
  }
}

void initPrintLogging(Level level) {
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

final _writeLock = Lock();
void initFileLogging(Level level) async {
  await checkUploadLogs();
  final stringBuffer = StringBuffer();
  var lines = 0;
  Logger.root.onRecord.listen((record) {
    _writeLock.synchronized(() async {
      stringBuffer.writeln(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
      if (record?.error != null) {
        stringBuffer.writeln(record.error);
      }
      if (record?.stackTrace != null) {
        stringBuffer.writeln(record.stackTrace);
      }
      lines++;
      if (lines > 100) {}
    });
  });
}

Future checkUploadLogs() async {
  final latestKey = 'LATEST-LOG-UPLOAD-MILLIS';
  // Get when file was uploaded to server latest
  final preferences = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final lastUploadMillis = preferences.getInt(latestKey);
  final lastUploadDate = lastUploadMillis == null
      ? DateTime.now()
      : DateTime.fromMillisecondsSinceEpoch(lastUploadMillis);
  // If more than 24 hours upload to server and reset file
  if (now.subtract(24.hours()).isAfter(lastUploadDate)) {
    // Save file to backend

    // Reset file

    // Set last upload date

  }
}

Future<bool> postLogFile(
  File file,
) async {
  final _log = Logger('postLogFile');
  try {
    final bytes = await file.readAsBytes();
    final baseUrl = await BaseUrlDb().getBaseUrl();

    final uri = Uri.parse('$baseUrl/open/v1/logs/');
    final request = MultipartRequest('POST', uri)
      ..files.add(MultipartFile.fromBytes(
        'file',
        bytes,
      ))
      ..fields.addAll({
        'owner': 'unknown',
        'app': 'seagull',
      });

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      return true;
    } else {
      final response = await Response.fromStream(streamedResponse);
      _log.warning(
          'Could not save file to backend ${streamedResponse.statusCode}, ${response.body}');
      return false;
    }
  } catch (e) {
    _log.severe('Could not save file to backend', e);
    return false;
  }
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
    if (event is Shout) {
      log.shout(transition);
    } else if (event is Warning) {
      log.warning(transition);
    } else if (event is Info) {
      log.info(transition);
    } else if (event is Fine) {
      log.fine(transition);
    } else if (event is Finest) {
      log.finest(transition);
    } else {
      log.finer(transition);
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
      _log.finest('didPush previousRoute $previousRoute');
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _log.fine('didReplace $newRoute');
      _log.finest('didReplace oldRoute $oldRoute');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _log.fine('didPop $route');
      _log.finest('didPop previousRoute $previousRoute');
    }
  }
}
