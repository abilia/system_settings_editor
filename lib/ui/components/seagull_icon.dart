import 'package:flutter/material.dart';

class SeagullIcon extends StatelessWidget {
  const SeagullIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(image: AssetImage('assets/graphics/seagull_icon_gray.png'));
  }
}
