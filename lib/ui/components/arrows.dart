import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/widgets.dart';

import 'package:seagull/ui/all.dart';

class VerticalScrollArrows extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final bool scrollbarAlwaysShown;

  const VerticalScrollArrows({
    Key key,
    @required this.controller,
    @required this.child,
    this.scrollbarAlwaysShown = false,
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
        ArrowDown(controller: controller),
      ],
    );
  }
}

class ArrowLeft extends StatelessWidget {
  final ScrollController controller;
  final double collapseMargin;

  const ArrowLeft({
    Key key,
    this.controller,
    this.collapseMargin = _Arrow.defaultCollapseMargin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: _Arrow(
          icon: AbiliaIcons.navigation_previous,
          borderRadius: const BorderRadius.only(
              topRight: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(-_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels - collapseMargin > sc.position.minScrollExtent,
        ),
      );
}

class ArrowUp extends StatelessWidget {
  final ScrollController controller;
  final double collapseMargin;

  const ArrowUp({
    Key key,
    this.controller,
    this.collapseMargin = _Arrow.defaultCollapseMargin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_up,
          borderRadius: const BorderRadius.only(
              bottomLeft: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(0, -_Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels - collapseMargin > sc.position.minScrollExtent,
        ),
      );
}

class ArrowRight extends StatelessWidget {
  final ScrollController controller;
  final double collapseMargin;
  const ArrowRight({
    Key key,
    this.controller,
    this.collapseMargin = _Arrow.defaultCollapseMargin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: _Arrow(
          icon: AbiliaIcons.navigation_next,
          borderRadius: const BorderRadius.only(
              topLeft: _Arrow.radius, bottomLeft: _Arrow.radius),
          vectorTranslation: Vector3(_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels + collapseMargin < sc.position.maxScrollExtent,
        ),
      );
}

class ArrowDown extends StatelessWidget {
  final ScrollController controller;
  final double collapseMargin;

  const ArrowDown({
    Key key,
    this.controller,
    this.collapseMargin = _Arrow.defaultCollapseMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigation_down,
          borderRadius: const BorderRadius.only(
              topLeft: _Arrow.radius, topRight: _Arrow.radius),
          vectorTranslation: Vector3(0, _Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.pixels + collapseMargin < sc.position.maxScrollExtent,
        ),
      );
}

class _Arrow extends StatefulWidget {
  static const Radius radius = Radius.circular(100);
  static const double arrowSize = 48.0;
  static const double translationPixels = arrowSize / 2;
  static const double defaultCollapseMargin = 2;
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
