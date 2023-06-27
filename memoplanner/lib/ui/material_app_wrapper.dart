import 'dart:async';

import 'package:collection/collection.dart';
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
        child: Builder(
          builder: (context) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              builder: (context, child) => child != null
                  ? MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                        alwaysUse24HourFormat: View.of(context)
                            .platformDispatcher
                            .alwaysUse24HourFormat,
                      ),
                      child: child,
                    )
                  : const SplashPage(),
              title: Config.flavor.name,
              theme: abiliaTheme,
              navigatorObservers: [
                AnalyticNavigationObserver(GetIt.I<SeagullAnalytics>()),
                NavigationObserver(context.read<NavigationCubit>()),
              ],
              supportedLocales: Lt.supportedLocales,
              localizationsDelegates: Lt.localizationsDelegates,
              localeListResolutionCallback: (locales, supportedLocales) {
                final language = locales
                    ?.firstWhereOrNull((l) => supportedLocales
                        .map((e) => e.languageCode)
                        .contains(l.languageCode))
                    ?.languageCode;
                final locale = supportedLocales
                        .firstWhereOrNull((l) => l.languageCode == language) ??
                    supportedLocales.first;
                unawaited(context.read<LocaleCubit>().setLocale(locale));
                return locale;
              },
              home: home,
            );
          },
        ),
      );
}
