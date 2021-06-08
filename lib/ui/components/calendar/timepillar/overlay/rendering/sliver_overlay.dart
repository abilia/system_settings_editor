// @dart=2.9

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../all.dart';

/// A sliver with a [RenderBox] as overlay and a [RenderSliver] as child.
///
/// The [overlay] stays pinned when it hits the start of the viewport until
/// the [child] scrolls off the viewport.
class RenderSliverOverlay extends RenderSliver with RenderSliverHelpers {
  RenderSliverOverlay({
    RenderObject overlay,
    RenderSliver child,
    double height = 0.0,
  }) : _height = height {
    this.overlay = overlay;
    this.child = child;
  }

  SliverOverlayState _oldState;
  double _overlayExtent;

  double get height => _height;
  double _height;
  set height(double value) {
    assert(value != null);
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  /// The render object's overlay
  RenderBox get overlay => _overlay;
  RenderBox _overlay;
  set overlay(RenderBox value) {
    if (_overlay != null) dropChild(_overlay);
    _overlay = value;
    if (_overlay != null) adoptChild(_overlay);
  }

  /// The render object's unique child
  RenderSliver get child => _child;
  RenderSliver _child;
  set child(RenderSliver value) {
    if (_child != null) dropChild(_child);
    _child = value;
    if (_child != null) adoptChild(_child);
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
    if (_overlay != null) _overlay.attach(owner);
    if (_child != null) _child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_overlay != null) _overlay.detach();
    if (_child != null) _child.detach();
  }

  @override
  void redepthChildren() {
    if (_overlay != null) redepthChild(_overlay);
    if (_child != null) redepthChild(_child);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_overlay != null) visitor(_overlay);
    if (_child != null) visitor(_child);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final result = <DiagnosticsNode>[];
    if (overlay != null) {
      result.add(overlay.toDiagnosticsNode(name: 'overlay'));
    }
    if (child != null) {
      result.add(child.toDiagnosticsNode(name: 'child'));
    }
    return result;
  }

  double computeOverlayExtent() {
    if (overlay == null) return 0.0;
    assert(overlay.hasSize);
    assert(constraints.axis != null);
    switch (constraints.axis) {
      case Axis.vertical:
        return overlay.size.height;
      case Axis.horizontal:
        return overlay.size.width;
    }
    return null;
  }

  double get overlayLogicalExtent => 0.0;

  @override
  void performLayout() {
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
          state: _oldState ?? SliverOverlayState(0.0),
          boxConstraints: boxConstraints,
        ),
        parentUsesSize: true,
      );
      _overlayExtent = computeOverlayExtent();
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
      if (childLayoutGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection,
        );
        return;
      }

      final paintExtent = math.min(
          overlayPaintExtent +
              math.max(childLayoutGeometry.paintExtent,
                  childLayoutGeometry.layoutExtent),
          constraints.remainingPaintExtent);

      geometry = SliverGeometry(
        scrollExtent: overlayExtent + childLayoutGeometry.scrollExtent,
        paintExtent: paintExtent,
        layoutExtent: math.min(
            overlayPaintExtent + childLayoutGeometry.layoutExtent, paintExtent),
        cacheExtent: math.min(
            overlayCacheExtent + childLayoutGeometry.cacheExtent,
            constraints.remainingCacheExtent),
        maxPaintExtent: overlayExtent + childLayoutGeometry.maxPaintExtent,
        hitTestExtent: math.max(
            overlayPaintExtent + childLayoutGeometry.paintExtent,
            overlayPaintExtent + childLayoutGeometry.hitTestExtent),
        hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
      );

      final SliverPhysicalParentData childParentData = child.parentData;
      assert(constraints.axisDirection != null);
      assert(constraints.growthDirection != null);
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
          childParentData.paintOffset = Offset(0.0,
              calculatePaintOffset(constraints, from: 0.0, to: overlayExtent));
          break;
        case AxisDirection.left:
          childParentData.paintOffset = Offset.zero;
          break;
      }
    }

    if (overlay != null) {
      final SliverPhysicalParentData overlayParentData = overlay.parentData;
      final childScrollExtent = child?.geometry?.scrollExtent ?? 0.0;
      final overlayPosition = math.min(constraints.overlap,
          childScrollExtent - constraints.scrollOffset - _overlayExtent);

      // second layout if scroll percentage changed and overlay is a RenderOverlayLayoutBuilder.
      if (overlay is RenderOverlayLayoutBuilder) {
        double scrollPercentage =
            ((overlayPosition - constraints.overlap).abs() / _overlayExtent)
                .clamp(0.0, 1.0);

        final state = SliverOverlayState(scrollPercentage);
        if (_oldState != state) {
          _oldState = state;
          overlay.layout(
            OverlayConstraints(
              state: _oldState,
              boxConstraints: boxConstraints,
            ),
            parentUsesSize: true,
          );
        }
      }

      final crossAxisOffset = 0.0;

      switch (axisDirection) {
        case AxisDirection.up:
          overlayParentData.paintOffset = Offset(crossAxisOffset,
              geometry.paintExtent - overlayPosition - _overlayExtent);
          break;
        case AxisDirection.down:
          overlayParentData.paintOffset =
              Offset(crossAxisOffset, overlayPosition);
          break;
        case AxisDirection.left:
          overlayParentData.paintOffset = Offset(
              geometry.paintExtent - overlayPosition - _overlayExtent,
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
      {@required double mainAxisPosition, @required double crossAxisPosition}) {
    assert(geometry.hitTestExtent > 0.0);
    if (overlay != null &&
        mainAxisPosition - constraints.overlap <= _overlayExtent) {
      return hitTestBoxChild(
              BoxHitTestResult.wrap(SliverHitTestResult.wrap(result)), overlay,
              mainAxisPosition: mainAxisPosition - constraints.overlap,
              crossAxisPosition: crossAxisPosition) ||
          (child != null &&
              child.geometry.hitTestExtent > 0.0 &&
              child.hitTest(result,
                  mainAxisPosition:
                      mainAxisPosition - childMainAxisPosition(child),
                  crossAxisPosition: crossAxisPosition));
    } else if (child != null && child.geometry.hitTestExtent > 0.0) {
      return child.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(child),
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderObject child) {
    if (child == overlay) {
      return 0.0;
    }
    if (child == this.child) {
      return calculatePaintOffset(constraints,
          from: 0.0, to: overlayLogicalExtent);
    }
    return null;
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    if (child == this.child) {
      return _overlayExtent;
    } else {
      return super.childScrollOffset(child);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    final SliverPhysicalParentData childParentData = child.parentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry.visible) {
      if (child != null && child.geometry.visible) {
        final SliverPhysicalParentData childParentData = child.parentData;
        context.paintChild(child, offset + childParentData.paintOffset);
      }

      // The overlay must be draw over the sliver.
      if (overlay != null) {
        final SliverPhysicalParentData overlayParentData = overlay.parentData;
        context.paintChild(overlay, offset + overlayParentData.paintOffset);
      }
    }
  }
}
