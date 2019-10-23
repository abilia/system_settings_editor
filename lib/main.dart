import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/bloc_delegate.dart';
import 'package:seagull/repository/user_repository.dart';
import 'package:seagull/ui/pages/login_page.dart';
import 'package:seagull/ui/pages/logout_page.dart';
import 'package:seagull/ui/pages/splash_page.dart';
import 'package:seagull/ui/theme.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'i18n/app_localizations.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  final UserRepository userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      builder: (context) =>
          AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
      child: MaterialApp(
        title: 'Seagull',
        theme: abiliaTheme,
        supportedLocales: AppLocalizations.SUPPORTED_LOCALES,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          // English should be the first one and also the default.
          return supportedLocales.first;
        },
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is AuthenticationAuthenticated) {
              return LogoutPage();
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: userRepository);
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
