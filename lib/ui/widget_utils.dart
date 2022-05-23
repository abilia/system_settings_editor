import 'package:seagull/ui/all.dart';

extension PaddingExtension on Widget {
  Widget pad(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets get onlyHorizontal => EdgeInsets.only(left: left, right: right);

  EdgeInsets get onlyVertical => EdgeInsets.only(top: top, bottom: bottom);
}

extension TtsExtension on Text {
  Tts withTts() {
    return Tts(
      child: this,
    );
  }
}
