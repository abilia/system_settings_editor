import 'package:flutter/widgets.dart';
import 'package:seagull/ui/colors.dart';

final _radius = const Radius.circular(12);

class CategoryRight extends StatelessWidget {
  final Widget child;
  const CategoryRight({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: _Category(
        child: child,
        borderRadius: BorderRadius.only(topLeft: _radius, bottomLeft: _radius),
      ),
    );
  }
}

class CategoryLeft extends StatelessWidget {
  final Widget child;
  const CategoryLeft({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: _Category(
        child: child,
        borderRadius:
            BorderRadius.only(topRight: _radius, bottomRight: _radius),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const _Category({
    Key key,
    this.child,
    this.borderRadius,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 38,
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AbiliaColors.white[135],
      ),
      child: Container(
        decoration: BoxDecoration(),
        child: Center(child: child),
      ),
    );
  }
}
