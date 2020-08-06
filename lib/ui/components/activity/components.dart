import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' show lerpDouble;

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class SubHeading extends StatelessWidget {
  final String data;
  const SubHeading(this.data, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(data),
    );
  }
}

class LinedBorder extends StatelessWidget {
  final Widget child;
  final GestureTapCallback onTap;
  final EdgeInsets padding;
  const LinedBorder({
    Key key,
    @required this.child,
    this.padding = const EdgeInsets.all(8),
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DottedBorder(
          dashPattern: [4, 4],
          borderType: BorderType.RRect,
          color: AbiliaColors.white140,
          radius: radius,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class PickField extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget leading, label;
  final double heigth;
  final bool active;
  final bool showTrailingArrow;

  const PickField({
    Key key,
    this.leading,
    this.label,
    this.onTap,
    this.heigth = 56,
    this.active = true,
    this.showTrailingArrow = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          height: heigth,
          decoration: active ? whiteBoxDecoration : borderDecoration,
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: <Widget>[
              Center(
                child: Row(
                  children: <Widget>[
                    if (leading != null) leading,
                    const SizedBox(width: 12),
                    if (label != null) label,
                  ],
                ),
              ),
              if (showTrailingArrow)
                Align(
                  alignment: Alignment.centerRight,
                  child: const Icon(
                    AbiliaIcons.navigation_next,
                    size: 32.0,
                    color: AbiliaColors.black60,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RadioField<T> extends StatelessWidget {
  final Widget child;
  final double heigth, width;
  final T value, groupValue;
  final ValueChanged<T> onChanged;
  final BoxDecoration activeDecoration;
  final BoxDecoration inactiveDecoration;
  final EdgeInsetsGeometry margin;

  const RadioField({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.child,
    this.heigth = 56,
    this.width,
    this.activeDecoration = whiteBoxDecoration,
    this.inactiveDecoration = borderDecoration,
    this.margin = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration =
        value == groupValue ? activeDecoration : inactiveDecoration;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: borderRadius,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Ink(
              height: heigth,
              width: width,
              decoration: decoration,
              padding: margin.subtract(decoration.border.dimensions),
              child: child,
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: AbiliaRadio(
                    key: ObjectKey(key),
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CollapsableWidget extends StatelessWidget {
  final Widget child;
  final bool collapsed;
  final EdgeInsets padding;
  final AlignmentGeometry alignment;

  const CollapsableWidget({
    Key key,
    @required this.child,
    @required this.collapsed,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topLeft,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final begin = collapsed ? 0.0 : 1.0;
    return TweenAnimationBuilder(
      duration: 300.milliseconds(),
      tween: Tween<double>(begin: begin, end: begin),
      child: child,
      builder: (context, value, widget) => ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: value,
          child: value > 0.0
              ? Padding(
                  padding: padding,
                  child: AbsorbPointer(
                    absorbing: collapsed,
                    child: widget,
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}

class SelectableField extends StatelessWidget {
  final Widget label;
  final double heigth, width;
  final bool selected;
  final GestureTapCallback onTap;

  const SelectableField({
    Key key,
    @required this.selected,
    @required this.onTap,
    @required this.label,
    this.heigth = 48,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Ink(
              height: heigth,
              width: width,
              decoration: selected ? whiteBoxDecoration : borderDecoration,
              padding: const EdgeInsets.only(left: 12.0, top: 6.0, right: 24.0),
              child: label,
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: AnimatedSwitcher(
                    duration: 300.milliseconds(),
                    transitionBuilder: (child, animation) => child is Container
                        ? child
                        : RotationTransition(
                            turns: animation,
                            child: ScaleTransition(
                              child: child,
                              scale: animation,
                            ),
                          ),
                    child: selected
                        ? Icon(
                            AbiliaIcons.radiocheckbox_selected,
                            color: AbiliaColors.green,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: border,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AbiliaRadio<T> extends StatefulWidget {
  const AbiliaRadio({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.activeColor,
    this.focusColor,
    this.hoverColor,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.outerRadius = 11.5,
    this.innerRadius = 8.5,
  })  : assert(autofocus != null),
        super(key: key);

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Color activeColor;
  final MaterialTapTargetSize materialTapTargetSize;
  final VisualDensity visualDensity;
  final Color focusColor;
  final Color hoverColor;
  final FocusNode focusNode;
  final bool autofocus;
  final double outerRadius;
  final double innerRadius;

  @override
  _AbiliaRadioState<T> createState() => _AbiliaRadioState<T>();
}

class _AbiliaRadioState<T> extends State<AbiliaRadio<T>>
    with TickerProviderStateMixin {
  bool get enabled => widget.onChanged != null;
  Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: _actionHandler,
      ),
    };
  }

  void _actionHandler(ActivateIntent intent) {
    if (widget.onChanged != null) {
      widget.onChanged(widget.value);
    }
    final renderObject = context.findRenderObject();
    renderObject.sendSemanticsEvent(const TapSemanticEvent());
  }

  bool _focused = false;
  void _handleHighlightChanged(bool focused) {
    if (_focused != focused) {
      setState(() {
        _focused = focused;
      });
    }
  }

  bool _hovering = false;
  void _handleHoverChanged(bool hovering) {
    if (_hovering != hovering) {
      setState(() {
        _hovering = hovering;
      });
    }
  }

  Color _getInactiveColor(ThemeData themeData) {
    return enabled ? themeData.unselectedWidgetColor : themeData.disabledColor;
  }

  void _handleChanged(bool selected) {
    if (selected) widget.onChanged(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final themeData = Theme.of(context);
    Size size;
    switch (widget.materialTapTargetSize ?? themeData.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        size = const Size(
            2 * kRadialReactionRadius + 8.0, 2 * kRadialReactionRadius + 8.0);
        break;
      case MaterialTapTargetSize.shrinkWrap:
        size = const Size(2 * kRadialReactionRadius, 2 * kRadialReactionRadius);
        break;
    }
    size +=
        (widget.visualDensity ?? themeData.visualDensity).baseSizeAdjustment;
    final additionalConstraints = BoxConstraints.tight(size);
    return FocusableActionDetector(
      actions: _actionMap,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: enabled,
      onShowFocusHighlight: _handleHighlightChanged,
      onShowHoverHighlight: _handleHoverChanged,
      child: Builder(
        builder: (BuildContext context) {
          return _RadioRenderObjectWidget(
            selected: widget.value == widget.groupValue,
            activeColor: widget.activeColor ?? themeData.toggleableActiveColor,
            inactiveColor: _getInactiveColor(themeData),
            focusColor: widget.focusColor ?? themeData.focusColor,
            hoverColor: widget.hoverColor ?? themeData.hoverColor,
            onChanged: enabled ? _handleChanged : null,
            additionalConstraints: additionalConstraints,
            vsync: this,
            hasFocus: _focused,
            hovering: _hovering,
            innerRadius: widget.innerRadius,
            outerRadius: widget.outerRadius,
          );
        },
      ),
    );
  }
}

class _RadioRenderObjectWidget extends LeafRenderObjectWidget {
  const _RadioRenderObjectWidget({
    Key key,
    @required this.selected,
    @required this.activeColor,
    @required this.inactiveColor,
    @required this.focusColor,
    @required this.hoverColor,
    @required this.additionalConstraints,
    this.onChanged,
    @required this.vsync,
    @required this.hasFocus,
    @required this.hovering,
    @required this.outerRadius,
    @required this.innerRadius,
  })  : assert(selected != null),
        assert(activeColor != null),
        assert(inactiveColor != null),
        assert(vsync != null),
        assert(innerRadius != null),
        assert(outerRadius != null),
        super(key: key);

  final bool selected;
  final bool hasFocus;
  final bool hovering;
  final Color inactiveColor;
  final Color activeColor;
  final Color focusColor;
  final Color hoverColor;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;
  final double outerRadius;
  final double innerRadius;

  @override
  _RenderRadio createRenderObject(BuildContext context) => _RenderRadio(
        value: selected,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        onChanged: onChanged,
        vsync: vsync,
        additionalConstraints: additionalConstraints,
        hasFocus: hasFocus,
        hovering: hovering,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRadio renderObject) {
    renderObject
      ..value = selected
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..focusColor = focusColor
      ..hoverColor = hoverColor
      ..onChanged = onChanged
      ..additionalConstraints = additionalConstraints
      ..vsync = vsync
      ..hasFocus = hasFocus
      ..hovering = hovering
      ..innerRadius = innerRadius
      ..outerRadius = outerRadius;
  }
}

class _RenderRadio extends RenderToggleable {
  _RenderRadio({
    bool value,
    Color activeColor,
    Color inactiveColor,
    Color focusColor,
    Color hoverColor,
    ValueChanged<bool> onChanged,
    BoxConstraints additionalConstraints,
    @required TickerProvider vsync,
    bool hasFocus,
    bool hovering,
    @required double outerRadius,
    @required double innerRadius,
  })  : _innerRadius = innerRadius,
        _outerRadius = outerRadius,
        super(
          value: value,
          tristate: false,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          onChanged: onChanged,
          additionalConstraints: additionalConstraints,
          vsync: vsync,
          hasFocus: hasFocus,
          hovering: hovering,
        );

  double _innerRadius;
  double get innerRadius => _innerRadius;
  set innerRadius(double value) {
    assert(value != null);
    if (value == _innerRadius) return;
    _innerRadius = value;
    markNeedsPaint();
  }

  double _outerRadius;
  double get outerRadius => _outerRadius;
  set outerRadius(double value) {
    assert(value != null);
    if (value == _outerRadius) return;
    _outerRadius = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    paintRadialReaction(canvas, offset, size.center(Offset.zero));

    final center = (offset & size).center;
    final radioColor = onChanged != null ? activeColor : inactiveColor;

    // Outer circle
    final paint = Paint()
      ..color = Color.lerp(inactiveColor, radioColor, position.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(1.0, 2.0, position.value);
    canvas.drawCircle(center, outerRadius, paint);

    // Inner circle
    if (!position.isDismissed) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, innerRadius * position.value, paint);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isInMutuallyExclusiveGroup = true
      ..isChecked = value == true;
  }
}
