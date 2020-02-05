import 'package:flutter/widgets.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:vector_math/vector_math_64.dart';

const Radius radius = Radius.circular(100);

class ArrowLeft extends StatelessWidget {
  final ScrollController controller;

  const ArrowLeft({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: ScrollArrows(
          child: _Arrow(
            icon: AbiliaIcons.navigation_previous,
            borderRadius:
                const BorderRadius.only(topRight: radius, bottomRight: radius),
            vectorTranslation: Vector3(-12, 0, 0),
            width: null,
          ),
          controller: controller,
          test: (sc) => sc.position.pixels != sc.position.minScrollExtent,
        ),
      );
}

class ArrowUp extends StatelessWidget {
  final ScrollController controller;

  const ArrowUp({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ScrollArrows(
            child: _Arrow(
              icon: AbiliaIcons.navigation_up,
              borderRadius: const BorderRadius.only(
                  bottomLeft: radius, bottomRight: radius),
              vectorTranslation: Vector3(0, -12, 0),
              heigth: null,
            ),
            controller: controller,
            test: (sc) => sc.position.pixels != sc.position.minScrollExtent),
      );
}

class ArrowRight extends StatelessWidget {
  final ScrollController controller;
  const ArrowRight({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: ScrollArrows(
            child: _Arrow(
              icon: AbiliaIcons.navigation_next,
              borderRadius:
                  const BorderRadius.only(topLeft: radius, bottomLeft: radius),
              vectorTranslation: Vector3(12, 0, 0),
              width: null,
            ),
            controller: controller,
            test: (sc) => sc.position.pixels != sc.position.maxScrollExtent),
      );
}

class ArrowDown extends StatelessWidget {
  final ScrollController controller;

  const ArrowDown({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: ScrollArrows(
            child: _Arrow(
              icon: AbiliaIcons.navigation_down,
              borderRadius:
                  const BorderRadius.only(topLeft: radius, topRight: radius),
              vectorTranslation: Vector3(0, 12, 0),
              heigth: null,
            ),
            controller: controller,
            test: (sc) => sc.position.pixels != sc.position.maxScrollExtent),
      );
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final BorderRadiusGeometry borderRadius;
  final double width, heigth;
  final Matrix4 translation;
  _Arrow(
      {this.icon,
      this.borderRadius,
      Vector3 vectorTranslation,
      this.width = 48,
      this.heigth = 48})
      : translation = Matrix4.translation(vectorTranslation);
  @override
  Widget build(BuildContext context) {
    return Container(
        transform: translation,
        width: width,
        height: heigth,
        decoration: BoxDecoration(
            borderRadius: borderRadius, color: AbiliaColors.white[135]),
        child: Icon(icon, size: 36));
  }
}

class ScrollArrows extends StatefulWidget {
  final ScrollController controller;
  final bool condition;
  final bool Function(ScrollController) test;
  final Widget child;

  const ScrollArrows(
      {Key key, this.controller, this.child, this.test, this.condition = true})
      : super(key: key);
  @override
  _VerticalScrollArrows createState() => _VerticalScrollArrows(condition);
}

class _VerticalScrollArrows extends State<ScrollArrows> {
  _VerticalScrollArrows(this.condition);
  bool condition = true;
  @override
  void initState() {
    widget.controller.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => condition ? widget.child : Container();

  void listener() {
    if (widget.test(widget.controller) != condition) {
      setState(() => condition = !condition);
    }
  }
}
