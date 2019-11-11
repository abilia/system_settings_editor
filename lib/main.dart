import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:seagull/bloc.dart';
import 'package:seagull/bloc/bloc_delegate.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';

import 'fakes/fake_client.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App(Client()));
}

class App extends StatelessWidget {
  final BaseClient httpClient;
  final UserRepository userRepository;

  App(
    this.httpClient, {
    Key key,
    FlutterSecureStorage secureStorage,
  })  : userRepository = UserRepository(
            httpClient: httpClient,
            secureStorage: secureStorage ?? FlutterSecureStorage()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      builder: (context) =>
          AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
      child: MaterialApp(
        title: 'Seagull',
        theme: abiliaTheme,
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [
          Translator.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
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
              return CalenderPage(authenticatedState: state);
            }
            if (state is Unauthenticated) {
              return LoginPage(userRepository: userRepository);
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
