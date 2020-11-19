import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:devicelocale/devicelocale.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:seagull/listener.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/tts/flutter_tts.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

final _log = Logger('main');

void main() async {
  runApp(App(initialization: initServices()));
}

@visibleForTesting
class InitValues {
  final String baseUrl;
  final NotificationAlarm payload;
  const InitValues(this.baseUrl, this.payload);
}

Future<InitValues> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();
  final seagullLogger = SeagullLogger(
    documentsDir: documentDirectory.path,
    preferences: preferences,
  );
  if (kReleaseMode) {
    await seagullLogger.initAnalytics();
  }
  _log.fine('Initializing services');
  await configureLocalTimeZone();
  final currentLocale = await Devicelocale.currentLocale;
  final settingsDb = SettingsDb(preferences);
  await settingsDb.setLanguage(currentLocale.split(RegExp('-|_'))[0]);
  final baseUrlDb = BaseUrlDb(preferences);
  GetItInitializer()
    ..documentsDirectory = documentDirectory
    ..sharedPreferences = preferences
    ..settingsDb = settingsDb
    ..baseUrlDb = baseUrlDb
    ..seagullLogger = seagullLogger
    ..database = await DatabaseRepository.createSqfliteDb()
    ..flutterTts = await flutterTts(currentLocale)
    ..init();

  final baseUrl = await baseUrlDb.initialize(kReleaseMode ? PROD : WHALE);
  final payload = Platform.isIOS ? null : await _payload;
  return InitValues(baseUrl, payload);
}

Future<NotificationAlarm> get _payload async {
  final notificationAppLaunchDetails =
      await notificationPlugin.getNotificationAppLaunchDetails();
  try {
    if (notificationAppLaunchDetails.didNotificationLaunchApp) {
      final payload =
          NotificationAlarm.decode(notificationAppLaunchDetails.payload);
      _log.fine('Notification Launched App with payload: $payload');
      return payload;
    }
  } catch (e) {
    _log.severe(
        'Could not parse payload: ${notificationAppLaunchDetails.payload}', e);
  }
  return null;
}

class App extends StatelessWidget {
  final PushBloc pushBloc;
  final Future<InitValues> initialization;

  App({
    Key key,
    this.pushBloc,
    this.initialization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialization ?? Future.value(InitValues('mock', null)),
      builder: (context, AsyncSnapshot<InitValues> snapshot) {
        if (snapshot.hasData) {
          return TopLevelBlocsProvider(
            pushBloc: pushBloc,
            baseUrl: snapshot.data.baseUrl,
            child: TopLevelListeners(
              child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) => AuthenticatedBlocsProvider(
                  authenticationState: state,
                  child: SeagullApp(
                    child: (state is Authenticated)
                        ? AuthenticatedListeners(
                            alarm: snapshot.data.payload,
                            child: snapshot.data.payload != null
                                ? FullScreenAlarm(alarm: snapshot.data.payload)
                                : CalendarPage(),
                          )
                        : (state is Unauthenticated)
                            ? LoginPage(
                                push: GetIt.I<FirebasePushService>(),
                                authState: state,
                              )
                            : const SplashPage(),
                  ),
                ),
              ),
            ),
          );
        }
        return const SplashPage();
      },
    );
  }
}

class SeagullApp extends MaterialApp {
  SeagullApp({
    Key key,
    Widget child,
  }) : super(
          key: key,
          builder: (context, child) {
            final deviceData = MediaQuery.of(context);
            GetIt.I<SettingsDb>()
                .setAlwaysUse24HourFormat(deviceData.alwaysUse24HourFormat);
            return MediaQuery(
              data: deviceData.copyWith(textScaleFactor: 1.0),
              child: child,
            );
          },
          title: 'MEMOplanner Go',
          theme: abiliaTheme,
          darkTheme: abiliaTheme.copyWith(
            primaryColorBrightness: Brightness.dark,
          ),
          navigatorObservers: [
            AnalyticsService.observer,
            GetIt.I<AlarmNavigator>().alarmRouteObserver,
            RouteLoggingObserver(),
          ],
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [
            Translator.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  // English should be the first one and also the default.
                  orElse: () => supportedLocales.first),
          home: child,
        );
}
