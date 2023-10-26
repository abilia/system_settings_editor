import 'package:flutter_test/flutter_test.dart';
import 'package:handi/main.dart';
import 'package:ui/components/buttons/action_button.dart';
import 'package:ui/components/combo_box.dart';

import 'finder_extensions.dart';

extension PumpAndSettleExtensions on WidgetTester {
  Future<void> pumpAndSettleHandiApp() async {
    await pumpWidget(const HandiApp());
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}

extension FindWidgetExtensions on WidgetTester {
  SeagullActionButton get loginButton =>
      widget<SeagullActionButton>(find.loginButton);

  SeagullComboBox get usernameField =>
      widget<SeagullComboBox>(find.usernameField);

  SeagullComboBox get passwordField =>
      widget<SeagullComboBox>(find.passwordField);
}
