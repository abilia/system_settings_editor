import 'package:memoplanner/ui/all.dart';
import 'package:vector_math/vector_math_64.dart';

class ScrollArrows extends StatelessWidget {
  final Widget child;
  final bool upArrow, downArrow, leftArrow, rightArrow;
  final double? upCollapseMargin, downCollapseMargin;
  final bool verticalScrollBar;
  final bool verticalScrollBarAlwaysShown;
  final ScrollController? verticalController, horizontalController;
  late final ValueNotifier<double?> maxScrollExtent = ValueNotifier(null);

  ScrollArrows.vertical({
    required this.child,
    this.upCollapseMargin,
    this.downCollapseMargin,
    bool hasScrollBar = true,
    bool scrollbarAlwaysShown = false,
    ScrollController? controller,
    Key? key,
  })  : assert(controller != null),
        verticalScrollBar = hasScrollBar,
        verticalController = controller,
        verticalScrollBarAlwaysShown = scrollbarAlwaysShown,
        upArrow = true,
        downArrow = true,
        leftArrow = false,
        rightArrow = false,
        horizontalController = null,
        super(key: key);

  ScrollArrows.all({
    required this.child,
    this.upCollapseMargin,
    this.downCollapseMargin,
    this.verticalScrollBar = false,
    this.verticalScrollBarAlwaysShown = false,
    this.verticalController,
    this.horizontalController,
    Key? key,
  })  : assert(verticalController != null && horizontalController != null),
        upArrow = true,
        downArrow = true,
        leftArrow = true,
        rightArrow = true,
        super(key: key);

  ScrollArrows.horizontal({
    required this.child,
    bool hasScrollBar = true,
    bool scrollbarAlwaysShown = false,
    ScrollController? controller,
    this.verticalScrollBar = false,
    this.verticalScrollBarAlwaysShown = false,
    Key? key,
  })  : assert(controller != null),
        upArrow = false,
        downArrow = false,
        leftArrow = true,
        rightArrow = true,
        upCollapseMargin = null,
        downCollapseMargin = null,
        verticalController = null,
        horizontalController = controller,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget scrollMetricsNotifyingChild =
        NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollMetricNotification) {
        maxScrollExtent.value =
            scrollMetricNotification.metrics.maxScrollExtent;
        return false;
      },
      child: child,
    );

    return ValueListenableBuilder(
      valueListenable: maxScrollExtent,
      builder: (context, value, child) {
        assert(child != null, 'child should never be null');
        return Stack(
          children: [
            if (child != null)
              if (verticalScrollBar)
                AbiliaScrollBar(
                  thumbVisibility: verticalScrollBarAlwaysShown,
                  controller: verticalController,
                  child: child,
                )
              else
                child,
            if (upArrow)
              Positioned.fill(
                child: _ArrowUp(
                  controller: verticalController,
                  collapseMargin: upCollapseMargin,
                ),
              ),
            if (downArrow)
              Positioned.fill(
                child: _ArrowDown(
                  controller: verticalController,
                  collapseMargin: downCollapseMargin,
                ),
              ),
            if (leftArrow)
              Positioned.fill(
                child: _ArrowLeft(
                  controller: horizontalController,
                ),
              ),
            if (rightArrow)
              Positioned.fill(
                child: _ArrowRight(
                  controller: horizontalController,
                ),
              ),
          ],
        );
      },
      child: scrollMetricsNotifyingChild,
    );
  }
}

class _ArrowLeft extends _ArrowBase {
  const _ArrowLeft({super.controller});

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
          conditionFunction: (sc) => sc.position.extentBefore > _collapseMargin,
        ),
      );
}

class _ArrowUp extends _ArrowBase {
  const _ArrowUp({
    super.controller,
    super.collapseMargin,
  });

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
          conditionFunction: (sc) => sc.position.extentBefore > _collapseMargin,
        ),
      );
}

class _ArrowRight extends _ArrowBase {
  const _ArrowRight({super.controller});

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
          conditionFunction: (sc) => sc.position.extentAfter > _collapseMargin,
        ),
      );
}

class _ArrowDown extends _ArrowBase {
  const _ArrowDown({
    super.controller,
    super.collapseMargin,
  });

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
          conditionFunction: (sc) => sc.position.extentAfter > _collapseMargin,
        ),
      );
}

abstract class _ArrowBase extends StatelessWidget {
  final ScrollController? controller;
  final double? collapseMargin;

  double get _collapseMargin => collapseMargin ?? layout.arrows.collapseMargin;

  const _ArrowBase({
    Key? key,
    this.controller,
    this.collapseMargin,
  }) : super(key: key);
}

class _Arrow extends StatefulWidget {
  static final Radius radius = Radius.circular(layout.arrows.radius);
  static final double arrowSize = layout.arrows.size;
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
    required this.conditionFunction,
    required Vector3 vectorTranslation,
    this.width,
    this.heigth,
    this.controller,
  })  : translation = Matrix4.identity(),
        hiddenTranslation = Matrix4.translation(vectorTranslation);

  @override
  _ArrowState createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool condition = false;

  ScrollController get controller =>
      widget.controller ?? PrimaryScrollController.of(context);

  @override
  void initState() {
    controller.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => listener());
    return ClipRect(
      child: AnimatedContainer(
        transform: condition ? widget.translation : widget.hiddenTranslation,
        width: widget.width != null
            ? condition
                ? widget.width
                : 0
            : null,
        height: widget.heigth != null
            ? condition
                ? widget.heigth
                : 0
            : null,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: AbiliaColors.white135,
        ),
        duration: const Duration(milliseconds: 200),
        child: Icon(widget.icon, size: layout.icon.small),
      ),
    );
  }

  void listener() {
    if (controller.hasClients &&
        controller.position.haveDimensions &&
        widget.conditionFunction(controller) != condition) {
      setState(() => condition = !condition);
    }
  }
}
