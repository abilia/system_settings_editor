import 'package:seagull/ui/all.dart';

extension PaddingExtension on Widget {
  Widget pad(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}
