import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/firebase_options.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/logging/bloc_logging_observer.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull_logging/seagull_logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('main');

void main() async {
  await initServices();
  if (Config.isMP) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  final payload = await getOrAddPayloadToStream();
  runApp(App(payload: payload));
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // DO NOT REMOVE. The isAutoInitEnabled call is needed to make push work
  // https://github.com/firebase/flutterfire/issues/6011
  // NOTE: Firebase messaging will stop working after hot restart
  FirebaseMessaging.instance.isAutoInitEnabled;
  final preferences = await SharedPreferences.getInstance();
  final supportId = await DeviceDb(preferences).getSupportId();
  await FirebaseCrashlytics.instance.setUserIdentifier(supportId);
  final documentDirectory = await getApplicationDocumentsDirectory();
  final seagullLogger = SeagullLogger(
    documentsDirectory: documentDirectory.path,
    supportId: supportId,
    preferences: preferences,
    app: Config.flavor.id,
  );
  _log.fine('Initializing services');
  final analytics = kReleaseMode
      ? await _initAnalytics(supportId, BaseUrlDb(preferences).environment)
      : SeagullAnalytics.empty();
  Bloc.observer = BlocLoggingObserver(analytics);
  await configureLocalTimeZone(log: _log);
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
    ..ttsHandler = await TtsInterface.implementation(
      voiceDb: VoiceDb(preferences),
      voicesPath: applicationSupportDirectory.path,
    )
    ..packageInfo = await PackageInfo.fromPlatform()
    ..delays = const Delays()
    ..analytics = analytics
    ..device = await Device.init()
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

Future<SeagullAnalytics> _initAnalytics(String supportId, String environment) =>
    SeagullAnalytics.init(
      project: Config.release && environment == prodName
          ? MixpanelProject.memoProd
          : MixpanelProject.sandbox,
      identifier: supportId,
      superProperties: {
        AnalyticsProperties.flavor: Config.flavor.name,
        AnalyticsProperties.release: Config.release,
        AnalyticsProperties.environment: environment,
      },
    );

class App extends StatelessWidget {
  final PushCubit? pushCubit;
  final NotificationAlarm? payload;

  const App({
    Key? key,
    this.payload,
    this.pushCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TopLevelProvider(
        pushCubit: pushCubit,
        child: Config.isMPGO
            ? AppEntry(payload: payload)
            : BlocBuilder<StartupCubit, StartupState>(
                builder: (context, productionGuideState) {
                  if (productionGuideState is StartupDone) {
                    return AppEntry(payload: payload);
                  }
                  if (productionGuideState is WelcomeGuide) {
                    return const StartupGuidePage();
                  }
                  return const ProductionGuidePage();
                },
              ),
      );
}

final _navigatorKey = GlobalKey<NavigatorState>();

class AppEntry extends StatelessWidget {
  const AppEntry({required this.payload, super.key});
  final NotificationAlarm? payload;
  @override
  Widget build(BuildContext context) {
    return AuthenticationBlocProvider(
      child: TopLevelListeners(
        navigatorKey: _navigatorKey,
        payload: payload,
        child: MaterialAppWrapper(
          navigatorKey: _navigatorKey,
        ),
      ),
    );
  }
}
