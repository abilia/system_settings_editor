import 'package:flutter/material.dart';
import 'package:seagull/config.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({Key? key, this.fit, this.width, this.height})
      : super(key: key);

  final BoxFit? fit;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Image(
        fit: fit,
        height: height,
        width: width,
        image: AssetImage('assets/graphics/${Config.flavor.id}/checkmark.png'));
  }
}
