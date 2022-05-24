import 'dart:async';
import 'dart:io';

import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/analytics/all.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/firebase_options.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('main');

void main() async {
  await initServices();
  if (Config.isMP) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  final payload = await getOrAddPayloadToStream();
  BlocOverrides.runZoned(
    () => runApp(
      App(
        payload: payload,
        runStartGuide: shouldRunStartGuide,
        analytics: Config.release,
      ),
    ),
    blocObserver: BlocLoggingObserver(analyticsLogging: Config.release),
  );
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final documentDirectory = await getApplicationDocumentsDirectory();
  final applicationSupportDirectory = await getApplicationSupportDirectory();
  final preferences = await SharedPreferences.getInstance();
  final seagullLogger = SeagullLogger(
    documentsDir: documentDirectory.path,
    preferences: preferences,
  );
  _log.fine('Initializing services');
  await configureLocalTimeZone(log: _log);
  final currentLocale = await Devicelocale.currentLocale;
  final settingsDb = SettingsDb(preferences);
  if (currentLocale != null) {
    await settingsDb.setLanguage(currentLocale.split(RegExp('-|_'))[0]);
  }
  final voiceDb = VoiceDb(preferences, applicationSupportDirectory.path);
  final baseUrlDb = BaseUrlDb(preferences);
  await baseUrlDb.initialize();
  GetItInitializer()
    ..documentsDirectory = documentDirectory
    ..applicationSupportDirectory = applicationSupportDirectory
    ..sharedPreferences = preferences
    ..settingsDb = settingsDb
    ..baseUrlDb = baseUrlDb
    ..seagullLogger = seagullLogger
    ..database = await DatabaseRepository.createSqfliteDb()
    ..voiceDb = voiceDb
    ..ttsHandler = await TtsInterface.implementation(voiceDb)
    ..packageInfo = await PackageInfo.fromPlatform()
    ..syncDelay = const SyncDelays()
    ..init();
}

Future<NotificationAlarm?> getOrAddPayloadToStream() async {
  final notificationAppLaunchDetails =
      await notificationPlugin.getNotificationAppLaunchDetails();
  try {
    final payload = notificationAppLaunchDetails?.payload;
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true) {
      _log.info('Notification Launched App with payload: $payload');
      if (payload != null) {
        if (Platform.isAndroid) {
          _log.info('on android, parsing payload for fullscreen alarm');
          return NotificationAlarm.decode(payload);
        } else {
          _log.info('on ios, adding payload to selectNotificationSubject');
          onNotification(payload);
        }
      }
    }
  } catch (e) {
    _log.severe(
        'Could not parse payload: ${notificationAppLaunchDetails?.payload}', e);
  }
  return null;
}

bool get shouldRunStartGuide =>
    Config.isMP && GetIt.I<DeviceDb>().serialId.isEmpty;

class App extends StatelessWidget {
  final PushCubit? pushCubit;
  final NotificationAlarm? payload;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final bool runStartGuide, analytics;

  App({
    Key? key,
    this.payload,
    this.pushCubit,
    this.runStartGuide = false,
    this.analytics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TopLevelBlocsProvider(
        runStartGuide: runStartGuide,
        pushCubit: pushCubit,
        child: BlocBuilder<StartGuideCubit, StartGuideState>(
          builder: (context, startGuideState) =>
              startGuideState is StartGuideDone
                  ? TopLevelListener(
                      navigatorKey: _navigatorKey,
                      payload: payload,
                      child: SeagullApp(
                        navigatorKey: _navigatorKey,
                        analytics: analytics,
                      ),
                    )
                  : const StartGuidePage(),
        ),
      );
}

class SeagullApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool analytics;

  const SeagullApp({
    Key? key,
    required this.navigatorKey,
    this.analytics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: Config.isMP
            ? context.read<TouchDetectionCubit>().onPointerDown
            : null,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) => child != null
              ? MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child,
                )
              : const SplashPage(),
          title: Config.flavor.name,
          theme: abiliaTheme,
          navigatorObservers: [
            if (analytics) AnalyticsService.observer,
            RouteLoggingObserver(),
          ],
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: const [
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
          home: const SplashPage(),
        ),
      );
}
