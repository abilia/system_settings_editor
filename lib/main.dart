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

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({
    BaseClient client,
    String baseUrl,
    Key key,
    FlutterSecureStorage secureStorage,
  })  : userRepository = UserRepository(
            baseUrl: baseUrl ?? T1,
            client: client ?? Client(),
            secureStorage: secureStorage ?? FlutterSecureStorage()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      builder: (context) =>
          AuthenticationBloc()..add(AppStarted(userRepository)),
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
              return CalendarPage(authenticatedState: state);
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
