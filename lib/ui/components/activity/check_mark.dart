import 'package:flutter/material.dart';

class CheckMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/graphics/check_mark.png'));
  }
}

class CheckMarkWithBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/graphics/check_mark_border.png'));
  }
}
