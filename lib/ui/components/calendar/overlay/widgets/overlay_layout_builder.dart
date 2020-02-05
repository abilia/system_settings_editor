import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../all.dart';

typedef Widget OverlayLayoutWidgetBuilder(
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
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
  _OvlerlayLayoutBuilderElement(OverlayLayoutBuilder widget) : super(widget);

  @override
  OverlayLayoutBuilder get widget => super.widget;

  @override
  RenderOverlayLayoutBuilder get renderObject => super.renderObject;

  Element _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot); // Creates the renderObject.
    renderObject.callback = _layout;
  }

  @override
  void update(OverlayLayoutBuilder newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderObject.callback = _layout;
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
    renderObject.callback = null;
    super.unmount();
  }

  void _layout(OverlayConstraints constraints) {
    owner.buildScope(this, () {
      Widget built;
      if (widget.builder != null) {
        try {
          built = widget.builder(this, constraints);
          debugWidgetBuilderValue(widget, built);
        } catch (e, stack) {
          built = ErrorWidget.builder(
              _debugReportException('building $widget', e, stack));
        }
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
  void insertChildRenderObject(RenderObject child, slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final RenderOverlayLayoutBuilder renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

FlutterErrorDetails _debugReportException(
  String context,
  dynamic exception,
  StackTrace stack,
) {
  final FlutterErrorDetails details = FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'seagull overlay widgets library',
    context: ErrorDescription('context'),
  );
  FlutterError.reportError(details);
  return details;
}
