import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/config.dart';

String? _spoken;
const _ttsChannelName = Config.isMP ? 'acapela_tts' : 'flutter_tts';
// ignore: prefer_function_declarations_over_variables
final _ttsHandler = (MethodCall methodCall) {
  switch (methodCall.method) {
    case 'speak':
      if (_ttsChannelName == 'acapela_tts') {
        _spoken = methodCall.arguments['text'];
      } else {
        _spoken = methodCall.arguments;
      }
      break;
  }
};
void setupFakeTts() {
  _spoken = null;
  if (TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .checkMockMessageHandler(_ttsChannelName, _ttsHandler) ==
      false) {
    const MethodChannel(_ttsChannelName).setMockMethodCallHandler(_ttsHandler);
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

  Future verifyNoTts(Finder finder) async {
    _spoken = null;
    await longPress(finder);
    expect(_spoken, isNull);
  }
}
