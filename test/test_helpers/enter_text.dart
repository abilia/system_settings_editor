import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/widget_test_keys.dart';

extension OurEnterText on WidgetTester {
  Future<void> ourEnterText(Finder finder, String text) async {
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), text);
    await pumpAndSettle();
    await tap(find.byKey(TestKey.inputOk));
    await pumpAndSettle();
  }
}
