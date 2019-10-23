import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/pages/login_page.dart';

import 'i18n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seagull',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFE6E6E6),
          primaryColor: Colors.black,
          accentColor: Colors.white,
          fontFamily: 'Roboto',
          buttonTheme: ButtonThemeData(
              buttonColor: RED,
              shape: RoundedRectangleBorder(),
              textTheme: ButtonTextTheme.primary)),
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
