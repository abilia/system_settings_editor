import 'package:flutter/material.dart';

class CheckMark extends StatelessWidget {
  const CheckMark();
  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/graphics/check_mark.png'));
  }
}

class CheckMarkWithBorder extends StatelessWidget {
  const CheckMarkWithBorder();
  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/graphics/check_mark_border.png'));
  }
}
