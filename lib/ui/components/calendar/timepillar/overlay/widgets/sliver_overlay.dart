import 'package:flutter/widgets.dart';

import '../all.dart';

typedef SliverOverlayWidgetBuilder = Widget Function(
    BuildContext context, SliverOverlayState state);

@immutable
class SliverOverlayState {
  const SliverOverlayState(
    this.scrollPercentage,
  ) : assert(scrollPercentage != null);

  final double scrollPercentage;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! SliverOverlayState) return false;
    final SliverOverlayState typedOther = other;
    return scrollPercentage == typedOther.scrollPercentage;
  }

  @override
  int get hashCode => scrollPercentage.hashCode;

  @override
  String toString() => 'scrollPercentage: $scrollPercentage';
}

class SliverOverlay extends RenderObjectWidget {
  SliverOverlay({
    Key key,
    @required this.overlay,
    @required this.sliver,
    this.height,
  }) : super(key: key);

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
    renderObject..height = height;
  }
}

class SliverOverlayBuilder extends StatelessWidget {
  const SliverOverlayBuilder({
    Key key,
    @required this.builder,
    @required this.sliver,
    this.height,
  })  : assert(builder != null),
        super(key: key);

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
  SliverOverlayRenderObjectElement(SliverOverlay widget) : super(widget);

  @override
  SliverOverlay get widget => super.widget;

  Element _overlay;

  Element _sliver;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_overlay != null) visitor(_overlay);
    if (_sliver != null) visitor(_sliver);
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (child == _overlay) _overlay = null;
    if (child == _sliver) _sliver = null;
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _overlay = updateChild(_overlay, widget.overlay, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void update(SliverOverlay newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _overlay = updateChild(_overlay, widget.overlay, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void insertRenderObjectChild(
      covariant RenderObject child, covariant dynamic slot) {
    final RenderSliverOverlay renderObject = this.renderObject;
    if (slot == 0) renderObject.overlay = child;
    if (slot == 1) renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child,
      covariant dynamic oldSlot, covariant dynamic newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(
      covariant RenderObject child, covariant dynamic slot) {
    final RenderSliverOverlay renderObject = this.renderObject;
    if (renderObject.overlay == child) renderObject.overlay = null;
    if (renderObject.child == child) renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}
