import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/widget_test_keys.dart';

String? spoken;
void setupFakeTts() {
  spoken = null;
  MethodChannel('flutter_tts').setMockMethodCallHandler(
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'speak':
          spoken = methodCall.arguments;
          break;
      }
    },
  );
}

extension VerifyTts on WidgetTester {
  Future<void> enterText_(Finder finder, String text) async {
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), text);
    await pumpAndSettle();
    await tap(find.byKey(TestKey.inputOk));
    await pumpAndSettle();
  }

  Future verifyTts(Finder finder,
      {String? contains, String? exact, bool warnIfMissed = true}) async {
    await longPress(finder, warnIfMissed: warnIfMissed);
    final arg = spoken;
    if (arg == null) throw 'tts not called';
    if (contains != null) {
      expect(arg.toLowerCase().contains(contains.toLowerCase()), isTrue,
          reason: '$arg does not contain $contains');
    }
    if (exact != null) {
      expect(arg, exact);
    }
  }

  Future verifyNoTts(Finder finder) async {
    spoken = null;
    await longPress(finder);
    expect(spoken, isNull);
  }
}
