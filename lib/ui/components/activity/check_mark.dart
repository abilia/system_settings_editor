import 'package:flutter/material.dart';
import 'package:seagull/config.dart';

class CheckMark extends StatelessWidget {
  const CheckMark({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Image(
        image: AssetImage('assets/graphics/${Config.flavor.id}/checkmark.png'));
  }
}
