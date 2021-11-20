import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/widgets.dart';

import 'package:seagull/ui/all.dart';

class ArrowScrollable extends StatelessWidget {
  final Widget child;
  final bool upArrow, downArrow, leftArrow, rightArrow;
  final double? upCollapseMargin,
      downCollapseMargin,
      leftCollapseMargin,
      rightCollapseMargin;
  final bool verticalScrollBar;
  final bool verticalScrollbarAlwaysShown;
  final ScrollController? verticalController, horizontalController;
  late final ValueNotifier<ScrollMetrics?> scrollMetricsNotifier =
      ValueNotifier(null);

  ArrowScrollable({
    Key? key,
    required this.child,
    required this.upArrow,
    required this.downArrow,
    required this.leftArrow,
    required this.rightArrow,
    this.upCollapseMargin,
    this.downCollapseMargin,
    this.leftCollapseMargin,
    this.rightCollapseMargin,
    required this.verticalScrollBar,
    this.verticalScrollbarAlwaysShown = false,
    this.verticalController,
    this.horizontalController,
  }) : super(key: key);

  ArrowScrollable.verticalScrollArrows({
    Key? key,
    required this.child,
    this.upCollapseMargin,
    this.downCollapseMargin,
    bool hasScrollBar = true,
    bool scrollbarAlwaysShown = false,
    ScrollController? controller,
  })  : verticalScrollBar = hasScrollBar,
        verticalController = controller,
        verticalScrollbarAlwaysShown = scrollbarAlwaysShown,
        upArrow = true,
        downArrow = true,
        leftArrow = false,
        rightArrow = false,
        leftCollapseMargin = null,
        rightCollapseMargin = null,
        horizontalController = null,
        super(key: key);

  ArrowScrollable.allArrows({
    Key? key,
    required this.child,
    this.upCollapseMargin,
    this.downCollapseMargin,
    this.leftCollapseMargin,
    this.rightCollapseMargin,
    this.verticalScrollBar = false,
    this.verticalScrollbarAlwaysShown = false,
    this.verticalController,
    this.horizontalController,
  })  : upArrow = true,
        downArrow = true,
        leftArrow = true,
        rightArrow = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget scrollMetricsNotifyingChild =
        NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollMetricNotification) {
        scrollMetricsNotifier.value = scrollMetricNotification.metrics;
        return false;
      },
      child: child,
    );

    return ValueListenableBuilder(
        child: scrollMetricsNotifyingChild,
        valueListenable: scrollMetricsNotifier,
        builder: (context, value, child) {
          return Stack(
            children: [
              if (verticalScrollBar)
                AbiliaScrollBar(
                  isAlwaysShown: verticalScrollbarAlwaysShown,
                  controller: verticalController,
                  child: child!,
                ),
              if (!verticalScrollBar) child!,
              if (upArrow)
                _ArrowUp(
                  controller: verticalController,
                  collapseMargin: upCollapseMargin,
                ),
              if (downArrow)
                _ArrowDown(
                  controller: verticalController,
                  collapseMargin: downCollapseMargin,
                ),
              if (leftArrow)
                _ArrowLeft(
                  controller: horizontalController,
                  collapseMargin: leftCollapseMargin,
                ),
              if (rightArrow)
                _ArrowRight(
                  controller: horizontalController,
                  collapseMargin: rightCollapseMargin,
                ),
            ],
          );
        });
  }
}

class _ArrowLeft extends _ArrowBase {
  const _ArrowLeft({
    Key? key,
    ScrollController? controller,
    double? collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: _Arrow(
          icon: AbiliaIcons.navigationPrevious,
          borderRadius: BorderRadius.only(
              topRight: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(-_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.extentBefore > getCollapseMargin,
        ),
      );
}

class _ArrowUp extends _ArrowBase {
  const _ArrowUp({
    Key? key,
    ScrollController? controller,
    double? collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigationUp,
          borderRadius: BorderRadius.only(
              bottomLeft: _Arrow.radius, bottomRight: _Arrow.radius),
          vectorTranslation: Vector3(0, -_Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.extentBefore > getCollapseMargin,
        ),
      );
}

class _ArrowRight extends _ArrowBase {
  const _ArrowRight({
    Key? key,
    ScrollController? controller,
    double? collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: _Arrow(
          icon: AbiliaIcons.navigationNext,
          borderRadius: BorderRadius.only(
              topLeft: _Arrow.radius, bottomLeft: _Arrow.radius),
          vectorTranslation: Vector3(_Arrow.translationPixels, 0, 0),
          heigth: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.extentAfter > getCollapseMargin,
        ),
      );
}

class _ArrowDown extends _ArrowBase {
  const _ArrowDown({
    Key? key,
    ScrollController? controller,
    double? collapseMargin,
  }) : super(key: key, controller: controller, collapseMargin: collapseMargin);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: _Arrow(
          icon: AbiliaIcons.navigationDown,
          borderRadius: BorderRadius.only(
              topLeft: _Arrow.radius, topRight: _Arrow.radius),
          vectorTranslation: Vector3(0, _Arrow.translationPixels, 0),
          width: _Arrow.arrowSize,
          controller: controller,
          conditionFunction: (sc) =>
              sc.position.extentAfter > getCollapseMargin,
        ),
      );
}

abstract class _ArrowBase extends StatelessWidget {
  final ScrollController? controller;
  final double? collapseMargin;
  static final double defaultCollapseMargin = 2.0.s;
  double get getCollapseMargin => collapseMargin ?? defaultCollapseMargin;

  const _ArrowBase({
    Key? key,
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
  final double? width, heigth;
  final Matrix4 translation;
  final Matrix4 hiddenTranslation;
  final ScrollController? controller;
  final bool Function(ScrollController) conditionFunction;
  _Arrow({
    required this.icon,
    required this.borderRadius,
    required Vector3 vectorTranslation,
    this.width,
    this.heigth,
    this.controller,
    required this.conditionFunction,
  })  : translation = Matrix4.identity(),
        hiddenTranslation = Matrix4.translation(vectorTranslation);
  @override
  _ArrowState createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool condition = false;
  ScrollController? get controller =>
      widget.controller ?? PrimaryScrollController.of(context);

  @override
  void initState() {
    controller?.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    controller?.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) => listener());
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
        duration: const Duration(milliseconds: 200),
        child: Icon(widget.icon, size: smallIconSize),
      ),
    );
  }

  void listener() {
    final c = controller;
    if (c != null &&
        c.hasClients &&
        c.position.haveDimensions &&
        widget.conditionFunction(c) != condition) {
      setState(() => condition = !condition);
    }
  }
}
