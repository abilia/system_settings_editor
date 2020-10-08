import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:devicelocale/devicelocale.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'package:seagull/alarm_listener.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/tts/flutter_tts.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/background/all.dart';
import 'package:flutter/foundation.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/all.dart';

final _log = Logger('main');

void main() async {
  await initServices();
  final baseUrl = await BaseUrlDb().initialize(kReleaseMode ? PROD : WHALE);
  final payload = await _payload;
  runApp(App(baseUrl: baseUrl, notificationPayload: payload));
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userDb = UserDb();
  final seagullLogger = SeagullLogger(userDb: userDb);
  await seagullLogger.initLogging();
  _log.fine('Initializing services');
  final currentLocale = await Devicelocale.currentLocale;
  final settingsDb = SettingsDb(await SharedPreferences.getInstance());
  await settingsDb.setLanguage(currentLocale.split(RegExp('-|_'))[0]);
  final documentDirectory = await getApplicationDocumentsDirectory();
  GetItInitializer()
    ..fileStorage = FileStorage(documentDirectory.path)
    ..settingsDb = settingsDb
    ..userDb = userDb
    ..seagullLogger = seagullLogger
    ..database = await DatabaseRepository.createSqfliteDb()
    ..flutterTts = await flutterTts(currentLocale)
    ..init();
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
  final String baseUrl;
  final NotificationAlarm notificationPayload;
  bool get wasAlarmStart => notificationPayload != null && !Platform.isIOS;

  App({
    Key key,
    this.baseUrl,
    this.pushBloc,
    this.notificationPayload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: (context) => UserRepository(
        baseUrl: baseUrl,
        httpClient: GetIt.I<BaseClient>(),
        tokenDb: GetIt.I<TokenDb>(),
        userDb: GetIt.I<UserDb>(),
        licenseDb: GetIt.I<LicenseDb>(),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              database: GetIt.I<Database>(),
              baseUrlDb: GetIt.I<BaseUrlDb>(),
              seagullLogger: GetIt.I<SeagullLogger>(),
              cancleAllNotificationsFunction: () =>
                  notificationPlugin.cancelAll(),
            )..add(AppStarted(context.repository<UserRepository>())),
          ),
          BlocProvider<PushBloc>(
            create: (context) => pushBloc ?? PushBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.withTicker(GetIt.I<Ticker>()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: GetIt.I<SettingsDb>(),
            ),
          ),
        ],
        child: BlocListener<ClockBloc, DateTime>(
          listener: (context, state) async {
            await GetIt.I<SeagullLogger>().maybeUploadLogs();
          },
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return AuthenticatedBlocsProvider(
                  authenticatedState: state,
                  child: SeagullApp(
                    home: wasAlarmStart
                        ? SeagullListeners(
                            child: FullScreenAlarm(alarm: notificationPayload),
                            listenWhen: (_, current) =>
                                current is AlarmState &&
                                current.alarm != notificationPayload,
                          )
                        : SeagullListeners(child: CalendarPage()),
                  ),
                );
              }
              return SeagullApp(
                home: (state is Unauthenticated)
                    ? LoginPage(
                        userRepository: context.repository<UserRepository>(),
                        push: GetIt.I<FirebasePushService>(),
                      )
                    : SplashPage(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SeagullApp extends StatelessWidget {
  final Widget home;

  const SeagullApp({
    Key key,
    @required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        final deviceData = MediaQuery.of(context);
        GetIt.I<SettingsDb>()
            .setAlwaysUse24HourFormat(deviceData.alwaysUse24HourFormat);
        return MediaQuery(
          data: deviceData.copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
      title: 'Seagull',
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
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              // English should be the first one and also the default.
              orElse: () => supportedLocales.first),
      home: home,
    );
  }
}
