import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' show lerpDouble;

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SubHeading extends StatelessWidget {
  final String data;
  const SubHeading(this.data, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: data,
        header: true,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0.s),
        child: Text(
          data,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: AbiliaColors.black75),
        ),
      ),
    );
  }
}

class LinedBorder extends StatelessWidget {
  final Widget child;
  final GestureTapCallback onTap;
  final EdgeInsets padding;
  final bool errorState;
  const LinedBorder({
    Key key,
    @required this.child,
    this.padding,
    this.onTap,
    this.errorState = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: errorState
            ? Container(
                decoration: errorBoxDecoration,
                padding: padding,
                child: child,
              )
            : DottedBorder(
                dashPattern: [4.s, 4.s],
                strokeWidth: 1.0.s,
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
  static final trailingArrow = Icon(
    AbiliaIcons.navigation_next,
    size: defaultIconSize,
    color: AbiliaColors.black60,
  );
  final GestureTapCallback onTap;
  final Widget leading, trailing;
  final Text text;
  final double heigth;
  final bool errorState;
  final String semanticsLabel;
  static final defaultHeigth = 56.s;

  const PickField({
    @required this.text,
    Key key,
    this.leading,
    this.trailing,
    this.onTap,
    this.heigth,
    this.errorState = false,
    this.semanticsLabel,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data.isEmpty ? semanticsLabel : text.data,
        button: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            height: heigth ?? defaultHeigth,
            decoration: errorState
                ? whiteErrorBoxDecoration
                : onTap == null
                    ? disabledBoxDecoration
                    : whiteBoxDecoration,
            padding: EdgeInsets.all(12.s),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Row(
                    children: <Widget>[
                      if (leading != null)
                        IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(size: smallIconSize),
                          child: leading,
                        ),
                      SizedBox(width: 12.s),
                      if (text != null)
                        DefaultTextStyle(
                          style:
                              abiliaTextTheme.bodyText1.copyWith(height: 1.0),
                          child: text,
                        ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing ?? trailingArrow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadioField<T> extends StatelessWidget {
  final Widget leading, trailing;
  final Text text;
  final double heigth, width;
  final T value, groupValue;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry margin;
  static final defaultHeight = 56.s;
  static final defaultMargin =
      EdgeInsets.symmetric(horizontal: 12.0.s, vertical: 16.0.s);

  const RadioField({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.leading,
    this.trailing,
    this.text,
    this.heigth,
    this.width,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = selectedBoxDecoration(value == groupValue);
    final marginToUse = margin ?? defaultMargin;
    final left = marginToUse.resolve(text.textDirection).left;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data,
        selected: value == groupValue,
        toggled: value == groupValue,
        inMutuallyExclusiveGroup: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: heigth ?? defaultHeight,
                width: width,
                decoration: decoration,
                padding: marginToUse.subtract(decoration.border.dimensions),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(size: smallIconSize),
                          child: leading),
                      SizedBox(width: left),
                    ],
                    Expanded(
                      child: DefaultTextStyle(
                        style: abiliaTextTheme.bodyText1.copyWith(height: 1.0),
                        child: text,
                      ),
                    ),
                    if (trailing != null) ...[
                      trailing,
                      SizedBox(width: left),
                    ],
                  ],
                ),
              ),
              PositionedRadio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                radioKey: ObjectKey(key),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PositionedRadio<T> extends StatelessWidget {
  const PositionedRadio({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.radioKey,
  }) : super(key: key);

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Key radioKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -6.s,
      right: -6.s,
      child: Container(
        padding: EdgeInsets.all(4.0.s),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 24.s,
          height: 24.s,
          child: AbiliaRadio(
            key: radioKey,
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
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
  final Axis axis;

  const CollapsableWidget({
    Key key,
    @required this.child,
    @required this.collapsed,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topLeft,
    this.axis = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final begin = collapsed ? 0.0 : 1.0;
    final verical = axis == Axis.vertical;
    return TweenAnimationBuilder(
      duration: 300.milliseconds(),
      tween: Tween<double>(begin: begin, end: begin),
      builder: (context, value, widget) => ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: verical ? value : null,
          widthFactor: verical ? null : value,
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
      child: child,
    );
  }
}

class SelectableField extends StatelessWidget {
  final Text text;
  final double heigth, width;
  final bool selected;
  final GestureTapCallback onTap;

  static final defaultHeigth = 48.s;
  const SelectableField({
    Key key,
    @required this.selected,
    @required this.onTap,
    @required this.text,
    this.heigth,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = selectedBoxDecoration(selected);
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data,
        selected: selected,
        toggled: selected,
        inMutuallyExclusiveGroup: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: heigth ?? defaultHeigth,
                width: width,
                decoration: decoration,
                padding: EdgeInsets.fromLTRB(
                        12.0.s, 10.0.s, 26.0.s, decoration.border.bottom.width)
                    .subtract(decoration.border.dimensions),
                child: text,
              ),
              Positioned(
                top: -6.s,
                right: -6.s,
                child: Container(
                  padding: EdgeInsets.all(4.0.s),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 24.s,
                    height: 24.s,
                    child: AnimatedSwitcher(
                      duration: 300.milliseconds(),
                      transitionBuilder: (child, animation) =>
                          child is Container
                              ? child
                              : RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                      child: selected
                          ? Icon(
                              AbiliaIcons.radiocheckbox_selected,
                              color: AbiliaColors.green,
                              size: smallIconSize,
                            )
                          : Container(
                              decoration: BoxDecoration(
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
      ),
    );
  }
}

class AbiliaRadio<T> extends StatefulWidget {
  static final defaultOuterRadius = 11.5.s;
  static final defaultInnerRadius = 8.5.s;
  static final defaultRadialReactionRadius = kRadialReactionRadius.s;
  AbiliaRadio({
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
    this.outerRadius,
    this.innerRadius,
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
        size = Size(2 * kRadialReactionRadius + 8.0.s,
            2 * kRadialReactionRadius + 8.0.s);
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
            innerRadius: widget.innerRadius ?? AbiliaRadio.defaultInnerRadius,
            outerRadius: widget.outerRadius ?? AbiliaRadio.defaultOuterRadius,
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
          splashRadius: AbiliaRadio.defaultRadialReactionRadius,
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
      ..strokeWidth = lerpDouble(1.0.s, 2.0.s, position.value);
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
