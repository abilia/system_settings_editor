import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:devicelocale/devicelocale.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:seagull/alarm_listener.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/background/all.dart';

void main() async {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  await initServices();
  final baseUrl = await BaseUrlDb().initialize(PROD);

  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(App(baseUrl: baseUrl));
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  final currentLocale = await Devicelocale.currentLocale;
  await SettingsDb().setLanguage(currentLocale.split(RegExp('-|_'))[0]);
  final documentDirectory = await getApplicationDocumentsDirectory();
  GetItInitializer()
    ..fileStorage = FileStorage(documentDirectory.path)
    ..init();
}

class App extends StatelessWidget {
  final UserRepository userRepository;
  final PushBloc pushBloc;

  App({
    String baseUrl,
    Key key,
    this.pushBloc,
  })  : userRepository = UserRepository(
            baseUrl: baseUrl,
            httpClient: GetIt.I<BaseClient>(),
            tokenDb: GetIt.I<TokenDb>(),
            userDb: GetIt.I<UserDb>()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
                  databaseRepository: GetIt.I<DatabaseRepository>(),
                  baseUrlDb: GetIt.I<BaseUrlDb>(),
                  cancleAllNotificationsFunction: () =>
                      notificationPlugin.cancelAll(),
                )..add(AppStarted(userRepository))),
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
                    userRepository: userRepository,
                    push: GetIt.I<FirebasePushService>(),
                  )
                : SplashPage(),
          );
        },
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
        final mediaQuery =
            MediaQuery.of(context).copyWith(textScaleFactor: 1.0);
        SettingsDb().setAlwaysUse24HourFormat(mediaQuery.alwaysUse24HourFormat);
        return MediaQuery(
          child: child,
          data: mediaQuery,
        );
      },
      title: 'Seagull',
      theme: abiliaTheme,
      navigatorObservers: [AnalyticsService.observer],
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
