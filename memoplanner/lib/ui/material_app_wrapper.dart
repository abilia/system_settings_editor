import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';

class MaterialAppWrapper extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget home;

  const MaterialAppWrapper({
    Key? key,
    this.navigatorKey,
    this.home = const SplashPage(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => NavigationCubit(),
        child: Builder(builder: (context) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, child) => child != null
                ? MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: child,
                  )
                : const SplashPage(),
            title: Config.flavor.name,
            theme: abiliaTheme,
            navigatorObservers: [
              AnalyticNavigationObserver(GetIt.I<SeagullAnalytics>()),
              NavigationObserver(context.read<NavigationCubit>()),
            ],
            supportedLocales: Translator.supportedLocals,
            localizationsDelegates: [
              Translator.delegate,
              LocaleCubit.delegate(context.read<LocaleCubit>()),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) =>
                supportedLocales.firstWhere(
                    (l) => l.languageCode == locale?.languageCode,
                    // English should be the first one and also the default.
                    orElse: () => supportedLocales.first),
            home: home,
          );
        }),
      );
}
