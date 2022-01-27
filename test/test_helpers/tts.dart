import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String? _spoken;
void setupFakeTts() {
  _spoken = null;
  const MethodChannel('flutter_tts').setMockMethodCallHandler(
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'speak':
          _spoken = methodCall.arguments;
          break;
      }
    },
  );
}

extension VerifyTts on WidgetTester {
  Future verifyTts(
    Finder finder, {
    String? contains,
    String? exact,
    bool warnIfMissed = true,
    useTap = false,
  }) async {
    if (useTap) {
      await tap(finder, warnIfMissed: warnIfMissed);
    } else {
      await longPress(finder, warnIfMissed: warnIfMissed);
    }

    final arg = _spoken;
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
    _spoken = null;
    await longPress(finder);
    expect(_spoken, isNull);
  }
}
