import 'package:carymessenger/firebase_options.dart';
import 'package:carymessenger/getit_initializer.dart';
import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/listeners/top_level_listener.dart';
import 'package:carymessenger/providers.dart';
import 'package:carymessenger/ui/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
      child: AuthenticationBlocProvider(
        child: TopLevelListener(
          navigatorKey: _navigatorKey,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            localizationsDelegates: const [Lt.delegate],
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
