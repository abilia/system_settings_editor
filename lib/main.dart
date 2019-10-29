import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  App({Client httpClient, FlutterSecureStorage secureStorage})
      : userRepository = UserRepository(
            httpClient: httpClient ?? Client(),
            secureStorage: secureStorage ?? FlutterSecureStorage());

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
            if (state is Authenticated) {
              return MultiBlocProvider(
                  providers: [
                    BlocProvider<ActivitiesBloc>(
                        builder: (context) => ActivitiesBloc(
                            activitiesRepository: ActivityRepository(
                                authToken: state.token, userId: state.userId))
                          ..add(LoadActivities())),
                    BlocProvider<DayPickerBloc>(
                      builder: (context) => DayPickerBloc(),
                    ),
                    BlocProvider<FilteredActivitiesBloc>(
                      builder: (context) => FilteredActivitiesBloc(
                          activitiesBloc:
                              BlocProvider.of<ActivitiesBloc>(context),
                          dayPickerBloc:
                              BlocProvider.of<DayPickerBloc>(context)),
                    )
                  ],
                  child: ActivitiesPage(
                    authenticatedState: state,
                  ));
            }
            if (state is Unauthenticated) {
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
