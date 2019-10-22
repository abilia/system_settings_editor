import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/pages/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFE6E6E6),
          primaryColor: Colors.black,
          accentColor: Colors.white,
          fontFamily: 'Roboto',
          buttonTheme: ButtonThemeData(
              buttonColor: RED,
              shape: RoundedRectangleBorder(),
              textTheme: ButtonTextTheme.primary)),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
