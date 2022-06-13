import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/android_intents.dart';

class StartupGuidePage extends StatelessWidget {
  const StartupGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [
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
      theme: abiliaTheme,
      home: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WelcomePage(
              pageController: pageController,
            ),
            PageOne(
              pageController: pageController,
            ),
            PageTwo(
              pageController: pageController,
            ),
          ],
          controller: pageController,
        ),
        bottomNavigationBar: Padding(
          padding: layout.templates.m7.copyWith(top: 0),
          child: Row(
            children: const [
              AbiliaLogo(),
              Spacer(),
              IconActionButtonDark(
                onPressed: AndroidIntents.openSettings,
                child: Icon(AbiliaIcons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
