import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:seagull/ui/components/calendar/timepillar/overlay/all.dart';

/// A sliver with a [RenderBox] as overlay and a [RenderSliver] as child.
///
/// The [overlay] stays pinned when it hits the start of the viewport until
/// the [child] scrolls off the viewport.
class RenderSliverOverlay extends RenderSliver with RenderSliverHelpers {
  RenderSliverOverlay({
    RenderBox? overlay,
    RenderSliver? child,
    double height = 0.0,
  }) : _height = height {
    this.overlay = overlay;
    this.child = child;
  }

  SliverOverlayState? _oldState;
  late double _overlayExtent;

  double get height => _height;
  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  /// The render object's overlay
  RenderBox? get overlay => _overlay;
  RenderBox? _overlay;
  set overlay(RenderBox? value) {
    final overlay = _overlay;
    if (overlay != null) dropChild(overlay);
    _overlay = value;
    if (value != null) adoptChild(value);
  }

  /// The render object's unique child
  RenderSliver? get child => _child;
  RenderSliver? _child;
  set child(RenderSliver? value) {
    final child = _child;
    if (child != null) dropChild(child);
    _child = value;
    if (value != null) adoptChild(value);
  }

  BoxConstraints get boxConstraints => constraints.asBoxConstraints(
      crossAxisExtent: height, maxExtent: constraints.remainingPaintExtent);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _overlay?.attach(owner);
    _child?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _overlay?.detach();
    _child?.detach();
  }

  @override
  void redepthChildren() {
    final overlay = _overlay;
    if (overlay != null) redepthChild(overlay);
    final child = _child;
    if (child != null) redepthChild(child);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    final overlay = _overlay;
    if (overlay != null) visitor(overlay);
    final child = _child;
    if (child != null) visitor(child);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final result = <DiagnosticsNode>[];
    final overlay = _overlay;
    if (overlay != null) {
      result.add(overlay.toDiagnosticsNode(name: 'overlay'));
    }
    final child = _child;
    if (child != null) {
      result.add(child.toDiagnosticsNode(name: 'child'));
    }
    return result;
  }

  double computeOverlayExtent(RenderBox overlay) {
    switch (constraints.axis) {
      case Axis.vertical:
        return overlay.size.height;
      case Axis.horizontal:
        return overlay.size.width;
    }
  }

  double get overlayLogicalExtent => 0.0;

  @override
  void performLayout() {
    final overlay = _overlay;
    final child = _child;
    if (overlay == null && child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    // One of them is not null.
    final axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);

    if (overlay != null) {
      overlay.layout(
        OverlayConstraints(
          state: _oldState ?? const SliverOverlayState(0.0),
          boxConstraints: boxConstraints,
        ),
        parentUsesSize: true,
      );
      _overlayExtent = computeOverlayExtent(overlay);
    }

    // Compute the overlay extent only one time.
    final overlayExtent = overlayLogicalExtent;
    final overlayPaintExtent =
        calculatePaintOffset(constraints, from: 0.0, to: overlayExtent);
    final overlayCacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: overlayExtent);

    if (child == null) {
      geometry = SliverGeometry(
          scrollExtent: overlayExtent,
          maxPaintExtent: overlayExtent,
          paintExtent: overlayPaintExtent,
          cacheExtent: overlayCacheExtent,
          hitTestExtent: overlayPaintExtent,
          hasVisualOverflow: overlayExtent > constraints.remainingPaintExtent ||
              constraints.scrollOffset > 0.0);
    } else {
      child.layout(
        constraints.copyWith(
          scrollOffset: math.max(0.0, constraints.scrollOffset - overlayExtent),
          cacheOrigin: math.min(0.0, constraints.cacheOrigin + overlayExtent),
          overlap: 0.0,
          remainingPaintExtent:
              constraints.remainingPaintExtent - overlayPaintExtent,
          remainingCacheExtent:
              constraints.remainingCacheExtent - overlayCacheExtent,
        ),
        parentUsesSize: true,
      );
      final childLayoutGeometry = child.geometry;
      final scrollOffsetCorrection =
          childLayoutGeometry?.scrollOffsetCorrection;
      if (scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: scrollOffsetCorrection,
        );
        return;
      }

      final paintExtent = math.min(
          overlayPaintExtent +
              math.max(childLayoutGeometry?.paintExtent ?? 0.0,
                  childLayoutGeometry?.layoutExtent ?? 0.0),
          constraints.remainingPaintExtent);

      geometry = SliverGeometry(
        scrollExtent:
            overlayExtent + (childLayoutGeometry?.scrollExtent ?? 0.0),
        paintExtent: paintExtent,
        layoutExtent: math.min(
            overlayPaintExtent + (childLayoutGeometry?.layoutExtent ?? 0.0),
            paintExtent),
        cacheExtent: math.min(
            overlayCacheExtent + (childLayoutGeometry?.cacheExtent ?? 0.0),
            constraints.remainingCacheExtent),
        maxPaintExtent:
            overlayExtent + (childLayoutGeometry?.maxPaintExtent ?? 0.0),
        hitTestExtent: math.max(
            overlayPaintExtent + (childLayoutGeometry?.paintExtent ?? 0.0),
            overlayPaintExtent + (childLayoutGeometry?.hitTestExtent ?? 0.0)),
        hasVisualOverflow: childLayoutGeometry?.hasVisualOverflow ?? false,
      );

      final childParentData = child.parentData;
      if (childParentData is SliverPhysicalParentData) {
        switch (axisDirection) {
          case AxisDirection.up:
            childParentData.paintOffset = Offset.zero;
            break;
          case AxisDirection.right:
            childParentData.paintOffset = Offset(
                calculatePaintOffset(constraints, from: 0.0, to: overlayExtent),
                0.0);
            break;
          case AxisDirection.down:
            childParentData.paintOffset = Offset(
                0.0,
                calculatePaintOffset(constraints,
                    from: 0.0, to: overlayExtent));
            break;
          case AxisDirection.left:
            childParentData.paintOffset = Offset.zero;
            break;
        }
      }
    }

    final overlayParentData = overlay?.parentData;
    if (overlay != null && overlayParentData is SliverPhysicalParentData) {
      final childScrollExtent = child?.geometry?.scrollExtent ?? 0.0;
      final overlayPosition = math.min(constraints.overlap,
          childScrollExtent - constraints.scrollOffset - _overlayExtent);

      // second layout if scroll percentage changed and overlay is a RenderOverlayLayoutBuilder.
      if (overlay is RenderOverlayLayoutBuilder) {
        final scrollPercentage =
            ((overlayPosition - constraints.overlap).abs() / _overlayExtent)
                .clamp(0.0, 1.0);

        final state = SliverOverlayState(scrollPercentage);
        if (_oldState != state) {
          _oldState = state;
          overlay.layout(
            OverlayConstraints(
              state: state,
              boxConstraints: boxConstraints,
            ),
            parentUsesSize: true,
          );
        }
      }

      const crossAxisOffset = 0.0;

      switch (axisDirection) {
        case AxisDirection.up:
          overlayParentData.paintOffset = Offset(
              crossAxisOffset,
              (geometry?.paintExtent ?? 0.0) -
                  overlayPosition -
                  _overlayExtent);
          break;
        case AxisDirection.down:
          overlayParentData.paintOffset =
              Offset(crossAxisOffset, overlayPosition);
          break;
        case AxisDirection.left:
          overlayParentData.paintOffset = Offset(
              (geometry?.paintExtent ?? 0.0) - overlayPosition - _overlayExtent,
              crossAxisOffset);
          break;
        case AxisDirection.right:
          overlayParentData.paintOffset =
              Offset(overlayPosition, crossAxisOffset);
          break;
      }
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final geometry = this.geometry;
    assert(geometry != null && geometry.hitTestExtent > 0.0);
    final overlay = _overlay;
    final child = _child;
    final childGeometry = child?.geometry;
    if (overlay != null &&
        mainAxisPosition - constraints.overlap <= _overlayExtent) {
      return hitTestBoxChild(
              BoxHitTestResult.wrap(SliverHitTestResult.wrap(result)), overlay,
              mainAxisPosition: mainAxisPosition - constraints.overlap,
              crossAxisPosition: crossAxisPosition) ||
          (child != null &&
              childGeometry != null &&
              childGeometry.hitTestExtent > 0.0 &&
              child.hitTest(result,
                  mainAxisPosition:
                      mainAxisPosition - childMainAxisPosition(child),
                  crossAxisPosition: crossAxisPosition));
    } else if (child != null &&
        childGeometry != null &&
        childGeometry.hitTestExtent > 0.0) {
      return child.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(child),
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderObject child) {
    if (child == _overlay) {
      return 0.0;
    }
    if (child == _child) {
      return calculatePaintOffset(constraints,
          from: 0.0, to: overlayLogicalExtent);
    }
    return super.childMainAxisPosition(child);
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    if (child == _child) {
      return _overlayExtent;
    } else {
      return super.childScrollOffset(child);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry?.visible == true) {
      final child = _child;
      final childParentData = child?.parentData;
      if (child != null &&
          child.geometry?.visible == true &&
          childParentData is SliverPhysicalParentData) {
        context.paintChild(child, offset + childParentData.paintOffset);
      }

      // The overlay must be draw over the sliver.
      final overlay = _overlay;
      final overlayParentData = overlay?.parentData;
      if (overlay != null && overlayParentData is SliverPhysicalParentData) {
        context.paintChild(overlay, offset + overlayParentData.paintOffset);
      }
    }
  }
}
