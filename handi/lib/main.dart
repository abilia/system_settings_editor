import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/firebase_options.dart';
import 'package:handi/getit_initializer.dart';
import 'package:handi/listeners/top_level_listener.dart';
import 'package:handi/logging/bloc_logging_observer.dart';
import 'package:handi/providers.dart';

const appName = 'handi';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = BlocLoggingObserver();
  await initGetIt();
  runApp(
    const HandiApp(),
  );
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
            navigatorKey: _navigatorKey,
            home: Scaffold(
              body: Center(
                child: Text('${appName.toUpperCase()}!'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
