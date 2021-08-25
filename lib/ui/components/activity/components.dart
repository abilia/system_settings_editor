import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SubHeading extends StatelessWidget {
  final String data;
  const SubHeading(this.data, {Key? key}) : super(key: key);
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
              ?.copyWith(color: AbiliaColors.black75),
        ),
      ),
    );
  }
}

class LinedBorder extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final EdgeInsets padding;
  final bool errorState;
  const LinedBorder({
    Key? key,
    required this.child,
    required this.padding,
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
  final GestureTapCallback? onTap;
  final Widget? leading, trailing;
  final Text text;
  final double? heigth;
  final EdgeInsets? padding;
  final bool errorState;
  final String? semanticsLabel;
  static final defaultHeigth = 56.s;

  const PickField({
    required this.text,
    Key? key,
    this.leading,
    this.trailing,
    this.onTap,
    this.heigth,
    this.errorState = false,
    this.semanticsLabel,
    this.padding,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final l = leading;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data?.isEmpty == true ? semanticsLabel : text.data,
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
            padding: padding ?? EdgeInsets.all(12.s),
            child: Row(
              children: <Widget>[
                if (l != null)
                  IconTheme(
                    data: Theme.of(context)
                        .iconTheme
                        .copyWith(size: smallIconSize),
                    child: l,
                  ),
                SizedBox(width: 12.s),
                Expanded(
                  child: DefaultTextStyle(
                    overflow: TextOverflow.ellipsis,
                    style: (Theme.of(context).textTheme.bodyText1 ?? bodyText1)
                        .copyWith(height: 1.0),
                    child: text,
                  ),
                ),
                trailing ?? trailingArrow,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadioField<T> extends StatelessWidget {
  final Widget? leading;
  final Text text;
  final double? heigth, width;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final EdgeInsetsGeometry? padding;
  static final defaultHeight = 56.s;
  static final defaultPadding = EdgeInsets.symmetric(horizontal: 14.0.s);

  const RadioField({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
    this.leading,
    this.heigth,
    this.width,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = selectableBoxDecoration(value == groupValue);
    final paddingToUse = padding ?? defaultPadding;
    final l = leading;
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
          onTap: onChanged != null ? () => onChanged?.call(value) : null,
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: heigth ?? defaultHeight,
                width: width,
                decoration: decoration,
                padding: paddingToUse
                    .subtract(decoration.border?.dimensions ?? EdgeInsets.zero)
                    .clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity),
                child: Row(
                  children: [
                    if (l != null) ...[
                      IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(size: smallIconSize),
                          child: l),
                      SizedBox(
                        width: paddingToUse.resolve(text.textDirection).left,
                      ),
                    ],
                    Expanded(
                      child: DefaultTextStyle(
                        style:
                            (Theme.of(context).textTheme.bodyText1 ?? bodyText1)
                                .copyWith(height: 1.0),
                        child: text,
                      ),
                    ),
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
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.radioKey,
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Key? radioKey;

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
    Key? key,
    required this.child,
    required this.collapsed,
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
      builder: (context, double value, widget) => ClipRect(
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
  final double? heigth, width;
  final bool selected;
  final GestureTapCallback onTap;

  static final defaultHeigth = 48.s;
  const SelectableField({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.text,
    this.heigth,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = selectableBoxDecoration(selected);
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
                padding: EdgeInsets.fromLTRB(12.0.s, 10.0.s, 26.0.s,
                        decoration.border?.bottom.width ?? 0.0)
                    .subtract(decoration.border?.dimensions ?? EdgeInsets.zero),
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
  static final outerRadius = 11.5.s;
  static final innerRadius = 8.5.s;
  const AbiliaRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  final T value;

  final T? groupValue;

  final ValueChanged<T?>? onChanged;

  final MouseCursor? mouseCursor;

  final bool toggleable;

  final Color? activeColor;

  final MaterialStateProperty<Color?>? fillColor;

  final MaterialTapTargetSize? materialTapTargetSize;

  final VisualDensity? visualDensity;

  final Color? focusColor;

  final Color? hoverColor;

  final MaterialStateProperty<Color?>? overlayColor;

  final double? splashRadius;

  final FocusNode? focusNode;

  final bool autofocus;

  bool get _selected => value == groupValue;

  @override
  _RadioState<T> createState() => _RadioState<T>();
}

class _RadioState<T> extends State<AbiliaRadio<T>>
    with TickerProviderStateMixin, ToggleableStateMixin {
  final _RadioPainter _painter = _RadioPainter();

  void _handleChanged(bool? selected) {
    if (selected == null) {
      widget.onChanged!(null);
      return;
    }
    if (selected) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  void didUpdateWidget(AbiliaRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._selected != oldWidget._selected) {
      animateToValue();
    }
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  ValueChanged<bool?>? get onChanged =>
      widget.onChanged != null ? _handleChanged : null;

  @override
  bool get tristate => widget.toggleable;

  @override
  bool? get value => widget._selected;

  MaterialStateProperty<Color?> get _widgetFillColor {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return widget.activeColor;
      }
      return null;
    });
  }

  MaterialStateProperty<Color> get _defaultFillColor {
    final themeData = Theme.of(context);
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return themeData.disabledColor;
      }
      if (states.contains(MaterialState.selected)) {
        return themeData.toggleableActiveColor;
      }
      return themeData.unselectedWidgetColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final themeData = Theme.of(context);
    final effectiveMaterialTapTargetSize = widget.materialTapTargetSize ??
        themeData.radioTheme.materialTapTargetSize ??
        themeData.materialTapTargetSize;
    final effectiveVisualDensity = widget.visualDensity ??
        themeData.radioTheme.visualDensity ??
        themeData.visualDensity;
    Size size;
    switch (effectiveMaterialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        size = const Size(kMinInteractiveDimension, kMinInteractiveDimension);
        break;
      case MaterialTapTargetSize.shrinkWrap:
        size = const Size(
            kMinInteractiveDimension - 8.0, kMinInteractiveDimension - 8.0);
        break;
    }
    size += effectiveVisualDensity.baseSizeAdjustment;

    final effectiveMouseCursor = MaterialStateProperty.resolveWith<MouseCursor>(
        (Set<MaterialState> states) {
      return MaterialStateProperty.resolveAs<MouseCursor?>(
              widget.mouseCursor, states) ??
          themeData.radioTheme.mouseCursor?.resolve(states) ??
          MaterialStateProperty.resolveAs<MouseCursor>(
              MaterialStateMouseCursor.clickable, states);
    });

    // Colors need to be resolved in selected and non selected states separately
    // so that they can be lerped between.
    final activeStates = states..add(MaterialState.selected);
    final inactiveStates = states..remove(MaterialState.selected);
    final effectiveActiveColor = widget.fillColor?.resolve(activeStates) ??
        _widgetFillColor.resolve(activeStates) ??
        themeData.radioTheme.fillColor?.resolve(activeStates) ??
        _defaultFillColor.resolve(activeStates);
    final effectiveInactiveColor = widget.fillColor?.resolve(inactiveStates) ??
        _widgetFillColor.resolve(inactiveStates) ??
        themeData.radioTheme.fillColor?.resolve(inactiveStates) ??
        _defaultFillColor.resolve(inactiveStates);

    final focusedStates = states..add(MaterialState.focused);
    final effectiveFocusOverlayColor =
        widget.overlayColor?.resolve(focusedStates) ??
            widget.focusColor ??
            themeData.radioTheme.overlayColor?.resolve(focusedStates) ??
            themeData.focusColor;

    final hoveredStates = states..add(MaterialState.hovered);
    final effectiveHoverOverlayColor =
        widget.overlayColor?.resolve(hoveredStates) ??
            widget.hoverColor ??
            themeData.radioTheme.overlayColor?.resolve(hoveredStates) ??
            themeData.hoverColor;

    final activePressedStates = activeStates..add(MaterialState.pressed);
    final effectiveActivePressedOverlayColor =
        widget.overlayColor?.resolve(activePressedStates) ??
            themeData.radioTheme.overlayColor?.resolve(activePressedStates) ??
            effectiveActiveColor.withAlpha(kRadialReactionAlpha);

    final inactivePressedStates = inactiveStates..add(MaterialState.pressed);
    final effectiveInactivePressedOverlayColor =
        widget.overlayColor?.resolve(inactivePressedStates) ??
            themeData.radioTheme.overlayColor?.resolve(inactivePressedStates) ??
            effectiveActiveColor.withAlpha(kRadialReactionAlpha);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: widget._selected,
      child: buildToggleable(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor: effectiveMouseCursor,
        size: size,
        painter: _painter
          ..position = position
          ..reaction = reaction
          ..reactionFocusFade = reactionFocusFade
          ..reactionHoverFade = reactionHoverFade
          ..inactiveReactionColor = effectiveInactivePressedOverlayColor
          ..reactionColor = effectiveActivePressedOverlayColor
          ..hoverColor = effectiveHoverOverlayColor
          ..focusColor = effectiveFocusOverlayColor
          ..splashRadius = widget.splashRadius ??
              themeData.radioTheme.splashRadius ??
              kRadialReactionRadius
          ..downPosition = downPosition
          ..isFocused = states.contains(MaterialState.focused)
          ..isHovered = states.contains(MaterialState.hovered)
          ..activeColor = effectiveActiveColor
          ..inactiveColor = effectiveInactiveColor,
      ),
    );
  }
}

class _RadioPainter extends ToggleablePainter {
  @override
  void paint(Canvas canvas, Size size) {
    paintRadialReaction(canvas: canvas, origin: size.center(Offset.zero));

    final center = (Offset.zero & size).center;

    // Outer circle
    final paint = Paint()
      ..color = Color.lerp(inactiveColor, activeColor, position.value)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, AbiliaRadio.outerRadius, paint);

    // Inner circle
    if (!position.isDismissed) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(
          center, AbiliaRadio.innerRadius * position.value, paint);
    }
  }
}
