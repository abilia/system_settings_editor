import 'package:memoplanner/ui/all.dart';

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

  EdgeInsets get onlyTop => EdgeInsets.only(top: top);

  EdgeInsets get onlyBottom => EdgeInsets.only(bottom: bottom);

  EdgeInsets get withoutTop => this - onlyTop;

  EdgeInsets get withoutBottom => this - onlyBottom;
}

extension TtsExtension on Text {
  Tts withTts() {
    return Tts(
      child: this,
    );
  }
}

extension ColumnSpacing on Column {
  Column spacing(double spacing) {
    final List<Widget> newChildren = [];

    for (int i = 0; i < children.length; i++) {
      newChildren
        ..add(children[i])
        ..add(SizedBox(height: spacing));
    }

    return Column(key: key, children: newChildren);
  }
}
