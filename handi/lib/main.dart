import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/background/notifications.dart';
import 'package:handi/firebase_options.dart';
import 'package:handi/getit_initializer.dart';
import 'package:handi/l10n/all.dart';
import 'package:handi/listeners/top_level_listener.dart';
import 'package:handi/providers.dart';
import 'package:handi/ui/components/backend_banner.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_logging/seagull_logging.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:utils/utils.dart';

final _log = Logger('main');

const appName = 'HandiCalendar6';

void main() async {
  await initServices();
  runApp(const HandiApp());
}

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureLocalTimeZone(log: _log);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.isAutoInitEnabled;
  await initializeNotificationPlugin();
  Bloc.observer =
      BlocLoggingObserver(SeagullAnalytics.empty(), isRelease: false);
  await initLokalise();
  await initGetIt();
}

final _navigatorKey = GlobalKey<NavigatorState>();

class HandiApp extends StatelessWidget {
  const HandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TopLevelProviders(
      child: AuthenticationBlocProvider(
        child: TopLevelListener(
          navigatorKey: _navigatorKey,
          child: MaterialApp(
            theme: AbiliaTheme.getThemeData(MediaQuery.of(context).size.width),
            navigatorKey: _navigatorKey,
            localizationsDelegates: const [Lt.delegate],
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
              child: child != null
                  ? BackendBanner(child: child)
                  : const _SplashScreen(),
            ),
            home: const _SplashScreen(),
          ),
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(appName),
      ),
    );
  }
}
