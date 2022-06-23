import 'package:flutter/material.dart';
import 'package:seagull/config.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({Key? key, this.fit}) : super(key: key);

  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Image(
        fit: fit,
        image: AssetImage('assets/graphics/${Config.flavor.id}/checkmark.png'));
  }
}
