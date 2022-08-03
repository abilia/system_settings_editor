import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
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
        analytics: Config.release,
      ),
    ),
    blocObserver: BlocLoggingObserver(analyticsLogging: Config.release),
  );
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // DO NOT REMOVE. The isAutoInitEnabled call is needed to make push work
  // https://github.com/firebase/flutterfire/issues/6011
  FirebaseMessaging.instance.isAutoInitEnabled;

  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();
  final seagullLogger = SeagullLogger(
    documentsDir: documentDirectory.path,
    preferences: preferences,
  );
  _log.fine('Initializing services');
  await configureLocalTimeZone(log: _log);
  final voiceDb = VoiceDb(preferences);
  final baseUrlDb = BaseUrlDb(preferences);
  await baseUrlDb.initialize();

  final applicationSupportDirectory = await getApplicationSupportDirectory();

  GetItInitializer()
    ..directories = Directories(
      applicationSupport: applicationSupportDirectory,
      documents: documentDirectory,
    )
    ..sharedPreferences = preferences
    ..baseUrlDb = baseUrlDb
    ..seagullLogger = seagullLogger
    ..database = await DatabaseRepository.createSqfliteDb()
    ..voiceDb = voiceDb
    ..ttsHandler = Config.isMPGO
        ? await FlutterTtsHandler.implementation()
        : await AcapelaTtsHandler.implementation(
            voiceDb: voiceDb,
            voicesPath: applicationSupportDirectory.path,
          )
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

class App extends StatelessWidget {
  final PushCubit? pushCubit;
  final NotificationAlarm? payload;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final bool analytics;

  App({
    Key? key,
    this.payload,
    this.pushCubit,
    this.analytics = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TopLevelProvider(
        pushCubit: pushCubit,
        child: BlocBuilder<StartupCubit, StartupState>(
          builder: (context, productionGuideState) =>
              productionGuideState is StartupDone
                  ? AuthenticationBlocProvider(
                      child: TopLevelListener(
                        navigatorKey: _navigatorKey,
                        payload: payload,
                        child: SeagullApp(
                          navigatorKey: _navigatorKey,
                          analytics: analytics,
                        ),
                      ),
                    )
                  : productionGuideState is WelcomeGuide
                      ? const StartupGuidePage()
                      : const ProductionGuidePage(),
        ),
      );
}
