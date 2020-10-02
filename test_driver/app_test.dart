/*
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

// To run the driver tests: flutter drive --target=test_driver/app.dart
void main() {
  group('Counter App', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('Log in and take screenshot', () async {
      await driver.tap(find.byValueKey('userName'));
      await driver.enterText('flutter');
      await driver.tap(find.byValueKey('password'));
      await driver.enterText('password');
      await driver.tap(find.byValueKey('loggIn'));
      await driver.waitFor(find.byValueKey('changeView'));
      final agendaScreenshot = await driver.screenshot();
      File('screenshots/agenda.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(agendaScreenshot);
    });
  });
}
*/