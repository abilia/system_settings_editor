import 'dart:async';

import 'package:carymessenger/cubit/production_guide_cubit.dart';
import 'package:carymessenger/firebase_options.dart';
import 'package:carymessenger/getit_initializer.dart';
import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/listeners/top_level_listener.dart';
import 'package:carymessenger/providers.dart';
import 'package:carymessenger/ui/pages/production_guide_page.dart';
import 'package:carymessenger/ui/pages/splash_page.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/backend_banner.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_logging/bloc_logging_observer.dart';
import 'package:seagull_logging/logging.dart';
import 'package:utils/timezone.dart';

final _log = Logger('main');

const appName = 'CARY MOBILE';

void main() async {
  await initServices();
  runApp(const CaryMobileApp());
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureLocalTimeZone(log: _log);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.isAutoInitEnabled;
  Bloc.observer =
      BlocLoggingObserver(SeagullAnalytics.empty(), isRelease: false);
  await initLokalise();
  await initGetIt();
}

final _navigatorKey = GlobalKey<NavigatorState>();

class CaryMobileApp extends StatelessWidget {
  const CaryMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TopLevelProviders(
      child: BlocBuilder<ProductionGuideCubit, ProductionGuideState>(
        builder: (context, productionGuideState) =>
            switch (productionGuideState) {
          ProductionGuideNotDone() => const MaterialAppWrapper(
              home: ProductionGuidePage(),
            ),
          ProductionGuideDone() => AuthenticationBlocProvider(
              child: TopLevelListener(
                navigatorKey: _navigatorKey,
                child: const MaterialAppWrapper(
                  home: SplashPage(),
                ),
              ),
            ),
        },
      ),
    );
  }
}

class MaterialAppWrapper extends StatelessWidget {
  const MaterialAppWrapper({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: caryLightTheme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: child != null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.background,
                child: BackendBanner(child: child),
              )
            : const SplashPage(),
      ),
      supportedLocales: Lt.supportedLocales,
      localizationsDelegates: Lt.localizationsDelegates,
      localeListResolutionCallback: (locales, supportedLocales) {
        final language = locales
            ?.firstWhereOrNull((l) => supportedLocales
                .map((e) => e.languageCode)
                .contains(l.languageCode))
            ?.languageCode;
        return supportedLocales
                .firstWhereOrNull((l) => l.languageCode == language) ??
            supportedLocales.first;
      },
      home: home,
    );
  }
}
