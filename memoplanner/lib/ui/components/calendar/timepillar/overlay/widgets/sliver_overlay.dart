import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:memoplanner/ui/components/calendar/timepillar/overlay/all.dart';

typedef SliverOverlayWidgetBuilder = Widget Function(
    BuildContext context, SliverOverlayState state);

@immutable
class SliverOverlayState {
  const SliverOverlayState(this.scrollPercentage);

  final double scrollPercentage;

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! SliverOverlayState) return false;
    final typedOther = other;
    return scrollPercentage == typedOther.scrollPercentage;
  }

  @override
  int get hashCode => scrollPercentage.hashCode;

  @override
  String toString() => 'scrollPercentage: $scrollPercentage';
}

class SliverOverlay extends RenderObjectWidget {
  const SliverOverlay({
    required this.overlay,
    required this.sliver,
    required this.height,
    super.key,
  });

  final Widget overlay;

  final Widget sliver;

  final double height;

  @override
  RenderSliverOverlay createRenderObject(BuildContext context) {
    return RenderSliverOverlay(
      height: height,
    );
  }

  @override
  SliverOverlayRenderObjectElement createElement() =>
      SliverOverlayRenderObjectElement(this);

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverOverlay renderObject) {
    renderObject.height = height;
  }
}

class SliverOverlayBuilder extends StatelessWidget {
  const SliverOverlayBuilder({
    required this.builder,
    required this.sliver,
    required this.height,
    super.key,
  });

  final SliverOverlayWidgetBuilder builder;

  final Widget sliver;

  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverOverlay(
      height: height,
      sliver: sliver,
      overlay: OverlayLayoutBuilder(
        builder: (context, constraints) => builder(context, constraints.state),
      ),
    );
  }
}

class SliverOverlayRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  SliverOverlayRenderObjectElement(SliverOverlay super.widget);

  SliverOverlay get sliverOverlay => widget as SliverOverlay;

  Element? _overlay;

  Element? _sliver;

  @override
  void visitChildren(ElementVisitor visitor) {
    final overlay = _overlay;
    if (overlay != null) visitor(overlay);
    final sliver = _sliver;
    if (sliver != null) visitor(sliver);
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (child == _overlay) _overlay = null;
    if (child == _sliver) _sliver = null;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _overlay = updateChild(_overlay, sliverOverlay.overlay, 0);
    _sliver = updateChild(_sliver, sliverOverlay.sliver, 1);
  }

  @override
  void update(SliverOverlay newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _overlay = updateChild(_overlay, sliverOverlay.overlay, 0);
    _sliver = updateChild(_sliver, sliverOverlay.sliver, 1);
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant slot) {
    final renderObject = this.renderObject;
    if (renderObject is RenderSliverOverlay) {
      if (slot == 0) renderObject.overlay = child as RenderBox;
      if (slot == 1) renderObject.child = child as RenderSliver;
    }

    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, covariant oldSlot, covariant newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant slot) {
    final renderObject = this.renderObject;
    if (renderObject is RenderSliverOverlay) {
      if (renderObject.overlay == child) renderObject.overlay = null;
      if (renderObject.child == child) renderObject.child = null;
    }

    assert(renderObject == this.renderObject);
  }
}
