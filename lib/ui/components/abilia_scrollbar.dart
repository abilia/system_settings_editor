import 'package:flutter/cupertino.dart';
import 'package:seagull/ui/all.dart';

class AbiliaScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final bool isAlwaysShown;

  const AbiliaScrollBar({
    Key key,
    this.controller,
    this.child,
    this.isAlwaysShown = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => CupertinoScrollbar(
        controller: controller,
        isAlwaysShown: isAlwaysShown,
        thickness: CupertinoScrollbar.defaultThickness.s,
        thicknessWhileDragging:
            CupertinoScrollbar.defaultThicknessWhileDragging.s,
        radius: Radius.elliptical(
          CupertinoScrollbar.defaultRadius.x.s,
          CupertinoScrollbar.defaultRadius.y.s,
        ),
        radiusWhileDragging: Radius.elliptical(
          CupertinoScrollbar.defaultRadiusWhileDragging.x.s,
          CupertinoScrollbar.defaultRadiusWhileDragging.y.s,
        ),
        child: child,
      );
}
