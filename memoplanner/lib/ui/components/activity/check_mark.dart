import 'package:flutter/material.dart';
import 'package:memoplanner/config.dart';

enum CheckMarkSize { mini, small, medium }

class CheckMark extends StatelessWidget {
  final CheckMarkSize size;
  final BoxFit? fit;

  String get checkmarkImage {
    switch (size) {
      case CheckMarkSize.mini:
        return 'checkmark_mini.png';
      case CheckMarkSize.small:
        return 'checkmark_small.png';
      case CheckMarkSize.medium:
        return '${Config.flavor.id}/checkmark.png';
    }
  }

  const CheckMark({this.fit, this.size = CheckMarkSize.medium, super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      fit: fit,
      image: AssetImage('assets/graphics/$checkmarkImage'),
    );
  }
}
