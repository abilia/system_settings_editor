import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/pages/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seagull',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFE6E6E6),
          primaryColor: Colors.black,
          accentColor: Colors.white,
          fontFamily: 'Roboto',
          buttonTheme: ButtonThemeData(
              buttonColor: RED,
              shape: RoundedRectangleBorder(),
              textTheme: ButtonTextTheme.primary)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
