import 'package:auth/bloc/push/push_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:handi/firebase_options.dart';
import 'package:handi/getit_initializer.dart';
import 'package:handi/listeners/top_level_listener.dart';
import 'package:handi/providers.dart';

const appName = 'handi';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initGetIt();
  runApp(
    const HandiApp(),
  );
}

final _navigatorKey = GlobalKey<NavigatorState>();

class HandiApp extends StatelessWidget {
  final PushCubit? pushCubit;

  const HandiApp({super.key, this.pushCubit});

  @override
  Widget build(BuildContext context) {
    return Providers(
      pushCubit: pushCubit,
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
    );
  }
}
