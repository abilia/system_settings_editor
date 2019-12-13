import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import 'package:seagull/bloc.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/db/sqflite.dart';
import 'package:seagull/db/token_db.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/repository/push.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  initServices();
  final baseUrl = await BaseUrlDb().initialize(T1);
  runApp(App(
    baseUrl: baseUrl,
  ));
}

void initServices() {
  GetItInitializer().init();
}

class App extends StatelessWidget {
  final UserRepository userRepository;
  final PushBloc pushBloc;

  App({
    BaseClient httpClient,
    String baseUrl,
    Key key,
    this.pushBloc,
  })  : userRepository = UserRepository(
            baseUrl: baseUrl,
            httpClient: httpClient ?? GetIt.I<BaseClient>(),
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
                baseUrlDb: GetIt.I<BaseUrlDb>())
              ..add(AppStarted(userRepository))),
        BlocProvider<PushBloc>(
          create: (context) => pushBloc ?? PushBloc(),
        )
      ],
      child: MaterialApp(
        title: 'Seagull',
        theme: abiliaTheme,
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
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is Authenticated) {
              return CalendarPage(authenticatedState: state);
            }
            if (state is Unauthenticated) {
              return LoginPage(
                userRepository: userRepository,
                push: GetIt.I<FirebasePushService>(),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
