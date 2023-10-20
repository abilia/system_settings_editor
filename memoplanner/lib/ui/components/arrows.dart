import 'package:memoplanner/ui/all.dart';
import 'package:vector_math/vector_math_64.dart';

class ScrollArrows extends StatelessWidget {
  final Widget child;
  final bool upArrow, downArrow, leftArrow, rightArrow, verticalOverflowDivider;
  final EdgeInsets overflowDividerPadding;
  final double? upCollapseMargin, downCollapseMargin;
  final bool verticalScrollBar;
  final bool verticalScrollBarAlwaysShown;
  final ScrollController? verticalController, horizontalController;
  late final ValueNotifier<double?> maxScrollExtent = ValueNotifier(null);

  late final ValueNotifier<(double, double)?> scrollExtent =
      ValueNotifier(null);

  ScrollArrows.vertical({
    required this.child,
    required ScrollController? controller,
    this.upCollapseMargin,
    this.downCollapseMargin,
    this.verticalOverflowDivider = false,
    this.overflowDividerPadding = const EdgeInsets.all(0.0),
    bool hasScrollBar = true,
    bool scrollbarAlwaysShown = false,
    super.key,
  })  : assert(controller != null),
        verticalScrollBar = hasScrollBar,
        verticalController = controller,
        verticalScrollBarAlwaysShown = scrollbarAlwaysShown,
        upArrow = true,
        downArrow = true,
        leftArrow = false,
        rightArrow = false,
        horizontalController = null;

  ScrollArrows.all({
    required this.child,
    this.upCollapseMargin,
    this.downCollapseMargin,
    this.verticalScrollBar = false,
    this.verticalScrollBarAlwaysShown = false,
    this.verticalController,
    this.horizontalController,
    this.verticalOverflowDivider = false,
    super.key,
  })  : assert(verticalController != null && horizontalController != null),
        overflowDividerPadding = const EdgeInsets.all(0.0),
        upArrow = true,
        downArrow = true,
        leftArrow = true,
        rightArrow = true;

  ScrollArrows.horizontal({
    required this.child,
    required ScrollController? controller,
    this.verticalOverflowDivider = false,
    super.key,
  })  : assert(controller != null),
        overflowDividerPadding = const EdgeInsets.all(0.0),
        upArrow = false,
        downArrow = false,
        leftArrow = true,
        rightArrow = true,
        upCollapseMargin = null,
        downCollapseMargin = null,
        verticalController = null,
        verticalScrollBar = false,
        verticalScrollBarAlwaysShown = false,
        horizontalController = controller;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollMetricNotification) {
        maxScrollExtent.value =
            scrollMetricNotification.metrics.maxScrollExtent;
        final extentBefore = scrollMetricNotification.metrics.extentBefore;
        final extentAfter = scrollMetricNotification.metrics.extentAfter;
        scrollExtent.value = (
          extentBefore,
          extentAfter,
        );
        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: maxScrollExtent,
        builder: (context, maxScrollExtentValue, __) {
          return ValueListenableBuilder(
            valueListenable: scrollExtent,
            builder: (context, scrollExtentValue, __) {
              final extentBeforeValue = scrollExtentValue?.$1;
              final extentAfterValue = scrollExtentValue?.$2;
              return Stack(
                children: [
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
                  if (verticalOverflowDivider &&
                      extentAfterValue != null &&
                      extentAfterValue != 0)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: overflowDividerPadding,
                        child: Divider(
                          thickness: layout.checklist.dividerHeight,
                          endIndent: 0,
                        ),
                      ),
                    ),
                  if (verticalOverflowDivider &&
                      extentBeforeValue != null &&
                      extentBeforeValue != 0)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: overflowDividerPadding,
                        child: Divider(
                          thickness: layout.checklist.dividerHeight,
                          endIndent: 0,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
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
    this.controller,
    this.collapseMargin,
  });
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
