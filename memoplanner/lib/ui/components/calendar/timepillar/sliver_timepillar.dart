import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverTimePillar extends SingleChildRenderObjectWidget {
  const SliverTimePillar({
    super.key,
    super.child,
  });
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverTimePillar();
}

/// Adapted from [RenderSliverToBoxAdapter]
class RenderSliverTimePillar extends RenderSliverSingleBoxAdapter {
  Offset? _trailingEdgeOffset;

  RenderSliverTimePillar({
    super.child,
  });

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      this.geometry = SliverGeometry.zero;
      return;
    }

    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child.size.width;
        break;
      case Axis.vertical:
        childExtent = child.size.height;
        break;
    }

    final paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    final paintOrigin = constraints.remainingPaintExtent > childExtent
        ? constraints.scrollOffset
        : -(childExtent - constraints.remainingPaintExtent);

    final geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: true,
      visible: true,
    );
    this.geometry = geometry;
    setChildParentData(child, constraints, geometry);

    final childParentData = child.parentData;
    if (childParentData is SliverPhysicalParentData) {
      childParentData.paintOffset += Offset(paintOrigin, 0);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child != null && geometry?.visible == true) {
      final childParentData = child.parentData;
      if (childParentData is SliverPhysicalParentData) {
        if (!offTrailingEdge && startedClipping) {
          _trailingEdgeOffset = offset + childParentData.paintOffset;
        }

        final trailingEdgeOffset = _trailingEdgeOffset;
        if (offTrailingEdge && trailingEdgeOffset != null) {
          context.paintChild(child, trailingEdgeOffset);
          return;
        }

        context.paintChild(child, offset + childParentData.paintOffset);
      }
    }
  }

  bool get offTrailingEdge => constraints.remainingPaintExtent <= 0;
  bool get startedClipping =>
      constraints.remainingPaintExtent < (geometry?.maxPaintExtent ?? 0.0);
}
