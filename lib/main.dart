import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import 'package:seagull/bloc.dart';
import 'package:seagull/bloc/bloc_delegate.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
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
  final FirebasePushService firebasePushService;
  final PushBloc pushBloc;

  App({
    BaseClient httpClient,
    String baseUrl,
    TokenDb tokenDb,
    FirebasePushService firebasePushService,
    PushBloc pushBloc,
    Key key,
  })  : userRepository = UserRepository(
            baseUrl: baseUrl ?? T1,
            httpClient: httpClient ?? GetIt.I<Client>(),
            tokenDb: tokenDb ?? GetIt.I<TokenDb>(),
            userDb: GetIt.I<UserDb>()),
        firebasePushService =
            firebasePushService ?? GetIt.I<FirebasePushService>(),
        pushBloc = pushBloc ?? GetIt.I<PushBloc>(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
            builder: (context) => AuthenticationBloc(
                databaseRepository: GetIt.I<DatabaseRepository>(), baseUrlDb: BaseUrlDb())
              ..add(AppStarted(userRepository))),
        BlocProvider<PushBloc>(
          builder: (context) => pushBloc ?? PushBloc(),
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
                push: firebasePushService,
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
