import 'package:flutter/material.dart';
import 'package:handi/authentication_listener.dart';
import 'package:handi/getitinitialize.dart';
import 'package:handi/providers.dart';

const appName = 'handi';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetItInitializer().init();
  runApp(
    const HandiApp(),
  );
}

final _navigatorKey = GlobalKey<NavigatorState>();

class HandiApp extends StatelessWidget {
  const HandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Providers(
      child: AuthenticationListener(
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
