import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/widgets.dart';

import 'package:seagull/ui/all.dart';

class VerticalScrollArrows extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final bool scrollbarAlwaysShown;
  final double downCollapseMargin;

  const VerticalScrollArrows({
    Key key,
    @required this.controller,
    @required this.child,
    this.scrollbarAlwaysShown = false,
    this.downCollapseMargin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CupertinoScrollbar(
          isAlwaysShown: scrollbarAlwaysShown,
          controller: controller,
          child: child,
        ),
        ArrowUp(controller: controller),
        ArrowDown(
          controller: controller,
          collapseMargin: downCollapseMargin,
        ),
      ],
    );
  }
}

class ArrowLeft extends _ArrowBase {
  const ArrowLeft({
    Key key,
    ScrollController controller,
    double collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: _Arrow(
          icon: AbiliaIcons.navigation_previous,
          borderRadius: BorderRadius.only(
              topRight: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(-_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels - getCollapseMargin >
              sc.position.minScrollExtent,
        ),
      );
}

class ArrowUp extends _ArrowBase {
  const ArrowUp({
    Key key,
    ScrollController controller,
    double collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_up,
          borderRadius: BorderRadius.only(
              bottomLeft: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(0, -_Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels - getCollapseMargin >
              sc.position.minScrollExtent,
        ),
      );
}

class ArrowRight extends _ArrowBase {
  const ArrowRight({
    Key key,
    ScrollController controller,
    double collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: _Arrow(
          icon: AbiliaIcons.navigation_next,
          borderRadius: BorderRadius.only(
              topLeft: _Arrow.radius, bottomLeft: _Arrow.radius),
          vectorTranslation: Vector3(_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels + getCollapseMargin <
              sc.position.maxScrollExtent,
        ),
      );
}

class ArrowDown extends _ArrowBase {
  const ArrowDown({
    Key key,
    ScrollController controller,
    double collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_down,
          borderRadius: BorderRadius.only(
              topLeft: _Arrow.radius, topRight: _Arrow.radius),
          vectorTranslation: Vector3(0, _Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels + getCollapseMargin <
              sc.position.maxScrollExtent,
        ),
      );
}

abstract class _ArrowBase extends StatelessWidget {
  final ScrollController controller;
  final double collapseMargin;
  static final double defaultCollapseMargin = 2.0.s;
  double get getCollapseMargin => collapseMargin ?? defaultCollapseMargin;

  const _ArrowBase({
    Key key,
    this.controller,
    this.collapseMargin,
  }) : super(key: key);
}

class _Arrow extends StatefulWidget {
  static final Radius radius = Radius.circular(100.s);
  static final double arrowSize = 48.0.s;
  static final double translationPixels = arrowSize / 2;

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
  })  : assert(controller != null),
        assert(conditionFunction != null),
        translation = Matrix4.identity(),
        hiddenTranslation = Matrix4.translation(vectorTranslation);
  @override
  _ArrowState createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool condition = false;
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
  Widget build(BuildContext context) {
    if (widget.controller.hasClients &&
        widget.controller.position.haveDimensions &&
        condition != widget.conditionFunction(widget.controller)) {
      condition = widget.conditionFunction(widget.controller);
    }
    return ClipRect(
      child: AnimatedContainer(
        transform: condition ? widget.translation : widget.hiddenTranslation,
        width: widget.width != null
            ? condition
                ? widget.width
                : 1
            : null,
        height: widget.heigth != null
            ? condition
                ? widget.heigth
                : 1
            : null,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: AbiliaColors.white135,
        ),
        child: Icon(widget.icon, size: smallIconSize),
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  void listener() {
    if (widget.controller.hasClients &&
        widget.conditionFunction(widget.controller) != condition) {
      setState(() => condition = !condition);
    }
  }
}
