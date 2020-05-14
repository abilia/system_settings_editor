import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SliverTimePillar extends SingleChildRenderObjectWidget {
  SliverTimePillar({
    Key key,
    Widget child,
  }) : super(key: key, child: child);
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverTimePillar();
}

/// Adapted from [RenderSliverToBoxAdapter]
class RenderSliverTimePillar extends RenderSliverSingleBoxAdapter {
  Offset trailingEdgeOffset;

  RenderSliverTimePillar({
    RenderBox child,
  }) : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
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
    assert(childExtent != null);

    final paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    final paintOrigin = constraints.remainingPaintExtent > childExtent
        ? constraints.scrollOffset
        : -(childExtent - constraints.remainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: true,
      visible: true,
    );
    setChildParentData(child, constraints, geometry);
    final SliverPhysicalParentData childParentData = child.parentData;
    childParentData.paintOffset += Offset(paintOrigin, 0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry.visible) {
      final SliverPhysicalParentData childParentData = child.parentData;

      if (!offTrailingEdge && startedClippiing) {
        trailingEdgeOffset = offset + childParentData.paintOffset;
      }

      if (offTrailingEdge && trailingEdgeOffset != null) {
        context.paintChild(child, trailingEdgeOffset);
        return;
      }

      context.paintChild(child, offset + childParentData.paintOffset);
    }
  }

  bool get offTrailingEdge => constraints.remainingPaintExtent <= 0;
  bool get startedClippiing =>
      constraints.remainingPaintExtent < geometry.maxPaintExtent;
}
