import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/firebase_options.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('main');

void main() async {
  await initServices();
  if (Config.isMP) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  final payload = await getOrAddPayloadToStream();
  runApp(App(payload: payload));
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
    documentsDirectory: documentDirectory.path,
    preferences: preferences,
  );
  _log.fine('Initializing services');
  final analytics = kReleaseMode
      ? await SeagullAnalytics.init(
          clientId: await DeviceDb(preferences).getClientId(),
          environment: BaseUrlDb(preferences).environment,
        )
      : SeagullAnalytics.empty();
  Bloc.observer = BlocLoggingObserver(analytics);
  await configureLocalTimeZone(log: _log);
  final voiceDb = VoiceDb(preferences);
  final applicationSupportDirectory = await getApplicationSupportDirectory();
  GetItInitializer()
    ..directories = Directories(
      applicationSupport: applicationSupportDirectory,
      documents: documentDirectory,
      temp: await getTemporaryDirectory(),
    )
    ..sharedPreferences = preferences
    ..seagullLogger = seagullLogger
    ..database = await DatabaseRepository.createSqfliteDb()
    ..voiceDb = voiceDb
    ..ttsHandler = await TtsInterface.implementation(
      voiceDb: voiceDb,
      voicesPath: applicationSupportDirectory.path,
    )
    ..packageInfo = await PackageInfo.fromPlatform()
    ..syncDelay = const SyncDelays()
    ..analytics = analytics
    ..init();
}

Future<NotificationAlarm?> getOrAddPayloadToStream() async {
  final notificationAppLaunchDetails =
      await notificationPlugin.getNotificationAppLaunchDetails();
  try {
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true) {
      final notificationResponse =
          notificationAppLaunchDetails?.notificationResponse;
      _log.info(
        'Notification Launched App with notificationResponse: '
        '$notificationResponse',
      );
      if (notificationResponse != null) {
        if (Platform.isAndroid) {
          _log.info('on android, parsing payload for fullscreen alarm');
          final payload = notificationResponse.payload;
          if (payload != null) {
            return NotificationAlarm.decode(payload);
          }
        }
        _log.info('on iOS, adding payload to selectNotificationSubject');
        onNotification(notificationResponse);
      }
    }
  } catch (e) {
    _log.severe(
        'Could not parse notificationResponse: '
        '${notificationAppLaunchDetails?.notificationResponse}',
        e);
  }
  return null;
}

class App extends StatelessWidget {
  final PushCubit? pushCubit;
  final NotificationAlarm? payload;
  final _navigatorKey = GlobalKey<NavigatorState>();

  App({
    Key? key,
    this.payload,
    this.pushCubit,
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
                        child: MaterialAppWrapper(
                          navigatorKey: _navigatorKey,
                        ),
                      ),
                    )
                  : productionGuideState is WelcomeGuide
                      ? const StartupGuidePage()
                      : const ProductionGuidePage(),
        ),
      );
}
