import 'dart:async';

import 'package:collection/collection.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
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
                final languageCodes =
                    locales?.map((locale) => locale.languageCode).toList() ??
                        [];
                final locale = supportedLocales.firstWhereOrNull(
                        (l) => languageCodes.contains(l.languageCode)) ??
                    supportedLocales.first;
                unawaited(_updateLocale(context, locale));
                return locale;
              },
              home: home,
            );
          },
        ),
      );

  Future<void> _updateLocale(BuildContext context, Locale locale) async {
    GetIt.I<SeagullAnalytics>().setLocale(locale);
    await GetIt.I<SettingsDb>().setLanguage(locale.languageCode);
    if (Config.isMP && context.mounted) {
      await context.read<VoicesCubit>().setLanguage(locale.languageCode);
    }
  }
}
