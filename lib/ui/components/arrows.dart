import 'package:flutter/widgets.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:vector_math/vector_math_64.dart';

const Radius radius = Radius.circular(100);
const double arrowSize = 48.0;
const double translationPixels = arrowSize / 2;

class ArrowLeft extends StatelessWidget {
  final ScrollController controller;

  const ArrowLeft({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: _Arrow(
          icon: AbiliaIcons.navigation_previous,
          borderRadius:
              const BorderRadius.only(topRight: radius, bottomRight: radius),
          vectorTranslation: Vector3(-translationPixels, 0, 0),
          heigth: arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels > sc.position.minScrollExtent,
        ),
      );
}

class ArrowUp extends StatelessWidget {
  final ScrollController controller;

  const ArrowUp({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_up,
          borderRadius:
              const BorderRadius.only(bottomLeft: radius, bottomRight: radius),
          vectorTranslation: Vector3(0, -translationPixels, 0),
          width: arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels > sc.position.minScrollExtent,
        ),
      );
}

class ArrowRight extends StatelessWidget {
  final ScrollController controller;
  const ArrowRight({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: _Arrow(
          icon: AbiliaIcons.navigation_next,
          borderRadius:
              const BorderRadius.only(topLeft: radius, bottomLeft: radius),
          vectorTranslation: Vector3(translationPixels, 0, 0),
          heigth: arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels < sc.position.maxScrollExtent,
        ),
      );
}

class ArrowDown extends StatelessWidget {
  final ScrollController controller;

  const ArrowDown({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_down,
          borderRadius:
              const BorderRadius.only(topLeft: radius, topRight: radius),
          vectorTranslation: Vector3(0, translationPixels, 0),
          width: arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels < sc.position.maxScrollExtent,
        ),
      );
}

class _Arrow extends StatefulWidget {
  final IconData icon;
  final BorderRadiusGeometry borderRadius;
  final double width, heigth;
  final Matrix4 translation;
  final Matrix4 hiddenTranslation;
  final ScrollController controller;
  final bool Function(ScrollController) conditionFunction;
  _Arrow({
    @required this.icon,
    @required this.borderRadius,
    @required Vector3 vectorTranslation,
    this.width,
    this.heigth,
    @required this.controller,
    @required this.conditionFunction,
  })  : translation = Matrix4.identity(),
        hiddenTranslation = Matrix4.translation(vectorTranslation);
  _ArrowState createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool condition = true;
  @override
  void initState() {
    widget.controller.addListener(listener);
    WidgetsBinding.instance.addPostFrameCallback((_) => listener());
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: AnimatedContainer(
          transform: condition ? widget.translation : widget.hiddenTranslation,
          width: widget.width != null ? condition ? widget.width : 1 : null,
          height: widget.heigth != null ? condition ? widget.heigth : 1 : null,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: AbiliaColors.white135,
          ),
          child: Icon(widget.icon, size: 24),
          duration: const Duration(milliseconds: 200),
        ),
      );

  void listener() {
    if (widget.conditionFunction(widget.controller) != condition) {
      setState(() => condition = !condition);
    }
  }
}
