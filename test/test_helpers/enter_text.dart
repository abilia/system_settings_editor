import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/all.dart';

extension OurEnterText on WidgetTester {
  Future<void> ourEnterText(Finder finder, String text) async {
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), text);
    await pumpAndSettle();
    await tap(find.byKey(TestKey.inputOk));
    await pumpAndSettle();
  }

  Future<void> enterTime(Finder finder, String time) async {
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
    final chars = time.split('');
    for (var input in chars) {
      await tap(find.widgetWithText(KeyboardNumberButton, input));
      await pumpAndSettle();
    }
  }
}
