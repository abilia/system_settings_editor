import 'package:flutter/cupertino.dart';
import 'package:handi/ui/components/tts.dart';

extension TtsTextExtension on Text {
  Tts withTts() {
    return Tts(data: semanticsLabel ?? data ?? '', child: this);
  }
}

extension TtsWidgetExtension on Widget {
  Widget withTts(String data) {
    return Tts(data: data, child: this);
  }
}
