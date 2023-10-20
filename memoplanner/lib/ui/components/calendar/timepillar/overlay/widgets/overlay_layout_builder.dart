import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:memoplanner/ui/components/calendar/timepillar/overlay/all.dart';

typedef OverlayLayoutWidgetBuilder = Widget Function(
    BuildContext context, OverlayConstraints constraints);

/// Builds a widget tree that can depend on the [OverlayConstraints].
///
/// This is used by [SliverOverlayBuilder] to change the overlay layout
/// while it starts to scroll off the viewport.
class OverlayLayoutBuilder extends RenderObjectWidget {
  /// Creates a widget that defers its building until layout.
  ///
  /// The [builder] argument must not be null.
  const OverlayLayoutBuilder({
    required this.builder,
    super.key,
  });

  /// Called at layout time to construct the widget tree. The builder must not
  /// return null.
  final OverlayLayoutWidgetBuilder builder;

  @override
  RenderObjectElement createElement() => _OvlerlayLayoutBuilderElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderOverlayLayoutBuilder();

  // updateRenderObject is redundant with the logic in the _OverlayLayoutBuilderElement below.
}

class _OvlerlayLayoutBuilderElement extends RenderObjectElement {
  _OvlerlayLayoutBuilderElement(OverlayLayoutBuilder super.widget);

  OverlayLayoutBuilder get overlayLayoutBuilder =>
      widget as OverlayLayoutBuilder;

  RenderOverlayLayoutBuilder get renderOverlayLayoutBuilder =>
      renderObject as RenderOverlayLayoutBuilder;

  Element? _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    final child = _child;
    if (child != null) visitor(child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    super.forgetChild(child);
    _child = null;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot); // Creates the renderObject.
    renderOverlayLayoutBuilder.callback = _layout;
  }

  @override
  void update(OverlayLayoutBuilder newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderOverlayLayoutBuilder.callback = _layout;
    renderObject.markNeedsLayout();
  }

  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.
    renderObject.markNeedsLayout();
    super
        .performRebuild(); // Calls widget.updateRenderObject (a no-op in this case).
  }

  @override
  void unmount() {
    renderOverlayLayoutBuilder.callback = null;
    super.unmount();
  }

  void _layout(OverlayConstraints constraints) {
    owner?.buildScope(this, () {
      Widget built;

      try {
        built = overlayLayoutBuilder.builder(this, constraints);
        debugWidgetBuilderValue(widget, built);
      } catch (e, stack) {
        built = ErrorWidget.builder(
            _debugReportException('building $widget', e, stack));
      }

      try {
        _child = updateChild(_child, built, null);
        assert(_child != null);
      } catch (e, stack) {
        built = ErrorWidget.builder(
            _debugReportException('building $widget', e, stack));
        _child = updateChild(null, built, slot);
      }
    });
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        renderOverlayLayoutBuilder;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
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
    assert(renderOverlayLayoutBuilder.child == child);
    renderOverlayLayoutBuilder.child = null;
    assert(renderObject == this.renderObject);
  }
}

FlutterErrorDetails _debugReportException(
  String context,
  exception,
  StackTrace stack,
) {
  final details = FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'seagull overlay widgets library',
    context: ErrorDescription('context'),
  );
  FlutterError.reportError(details);
  return details;
}
