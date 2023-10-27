import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/buttons/action_button.dart';
import 'package:ui/components/combo_box.dart';

extension FinderExtensions on CommonFinders {
  Finder get usernameField => ancestor(
        of: byIcon(Symbols.account_circle),
        matching: byType(SeagullComboBox),
      );

  Finder get passwordField => ancestor(
        of: byIcon(Symbols.key),
        matching: byType(SeagullComboBox),
      );

  Finder get loginButton => widgetWithIcon(
        SeagullActionButton,
        Symbols.login,
      );
}
