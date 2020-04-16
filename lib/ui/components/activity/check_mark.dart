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

class CheckMarkWrapper extends StatelessWidget {
  final bool checked, small;
  final Widget child;
  const CheckMarkWrapper({Key key, this.checked, this.child, this.small = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: checked ? 0.5 : 1.0, child: child),
        if (checked)
          Positioned.fill(child: (small ? CheckMarkWithBorder() : CheckMark())),
      ],
    );
  }
}
