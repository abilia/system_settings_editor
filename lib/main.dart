import 'dart:async';

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
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/background/all.dart';
import 'package:flutter/foundation.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('main');

void main() async {
  await initServices();
  final baseUrl = await BaseUrlDb().initialize(PROD);
  runApp(App(baseUrl: baseUrl));
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLogging(initAppcenter: true);
  _log.fine('Initializing services');
  final currentLocale = await Devicelocale.currentLocale;
  final settingsDb = SettingsDb(await SharedPreferences.getInstance());
  await settingsDb.setLanguage(currentLocale.split(RegExp('-|_'))[0]);
  final documentDirectory = await getApplicationDocumentsDirectory();
  GetItInitializer()
    ..fileStorage = FileStorage(documentDirectory.path)
    ..settingsDb = settingsDb
    ..init();
}

class App extends StatelessWidget {
  final PushBloc pushBloc;
  final String baseUrl;

  App({
    Key key,
    this.baseUrl,
    this.pushBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: (context) => UserRepository(
          baseUrl: baseUrl,
          httpClient: GetIt.I<BaseClient>(),
          tokenDb: GetIt.I<TokenDb>(),
          userDb: GetIt.I<UserDb>()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                    databaseRepository: GetIt.I<DatabaseRepository>(),
                    baseUrlDb: GetIt.I<BaseUrlDb>(),
                    cancleAllNotificationsFunction: () =>
                        notificationPlugin.cancelAll(),
                  )..add(AppStarted(context.repository<UserRepository>()))),
          BlocProvider<PushBloc>(
            create: (context) => pushBloc ?? PushBloc(),
          ),
        ],
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return AuthenticatedBlocsProvider(
                authenticatedState: state,
                child: SeagullApp(
                  home: AlarmListener(child: CalendarPage()),
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
