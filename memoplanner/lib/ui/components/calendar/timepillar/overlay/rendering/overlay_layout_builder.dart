import 'package:flutter/rendering.dart';
import 'package:memoplanner/ui/components/calendar/timepillar/overlay/all.dart';

class RenderOverlayLayoutBuilder extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderOverlayLayoutBuilder({
    LayoutCallback<OverlayConstraints>? callback,
  }) : _callback = callback;

  LayoutCallback<OverlayConstraints>? get callback => _callback;
  LayoutCallback<OverlayConstraints>? _callback;
  set callback(LayoutCallback<OverlayConstraints>? value) {
    if (value == _callback) return;
    _callback = value;
    markNeedsLayout();
  }

  // layout input

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw FlutterError(
            'OverlayLayoutBuilder does not support returning intrinsic dimensions.\n'
            'Calculating the intrinsic dimensions would require running the layout '
            'callback speculatively, which might mutate the live render object tree.');
      }
      return true;
    }());
    return true;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  void performLayout() {
    assert(callback != null);
    invokeLayoutCallback(callback!);
    final child = this.child;
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child?.hitTest(result, position: position) ?? false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child != null) context.paintChild(child, offset);
  }
}
