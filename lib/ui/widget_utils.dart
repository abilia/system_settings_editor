import 'package:seagull/ui/all.dart';

extension PaddingExtension on Widget {
  Widget pad(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

extension TtsExtension on Text {
  Tts withTts() {
    return Tts(
      child: this,
    );
  }
}

extension AlignExtension on Widget {
  Widget align(Alignment alignment,
      {double? widthFactor, double? heightFactor}) {
    return Align(
        alignment: alignment,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this);
  }
}
