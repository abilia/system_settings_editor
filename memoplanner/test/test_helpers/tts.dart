import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String? _spoken;
const _ttsChannelName = 'flutter_tts';
Future _ttsHandler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'speak':
      _spoken = methodCall.arguments;
      break;
  }
}

void setupFakeTts() {
  _spoken = null;
  if (TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .checkMockMessageHandler(_ttsChannelName, _ttsHandler) ==
      false) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel(_ttsChannelName), _ttsHandler);
  }
}

extension VerifyTts on WidgetTester {
  Future verifyTts(
    Finder finder, {
    String? contains,
    String? exact,
    bool warnIfMissed = true,
    bool useTap = false,
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

  Future verifyNoTts([Finder? finder]) async {
    if (finder != null) await longPress(finder);
    expect(_spoken, isNull);
  }
}
