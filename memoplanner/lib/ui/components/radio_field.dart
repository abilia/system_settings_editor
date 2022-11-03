import 'package:memoplanner/ui/all.dart';

class RadioField<T> extends StatelessWidget {
  final Widget? leading;
  final Text text;
  final double? heigth, width;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final EdgeInsetsGeometry? padding;

  const RadioField({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
    this.leading,
    this.heigth,
    this.width,
    this.padding,
    Key? key,
  }) : super(key: key);

  bool get disabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final decoration = disabled
        ? disabledBoxDecoration
        : selected
            ? selectedBoxDecoration
            : whiteBoxDecoration;

    final paddingToUse = padding ?? layout.pickField.padding;
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
          onTap: disabled ? null : () => onChanged?.call(value),
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: heigth ?? layout.pickField.height,
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
                              .copyWith(size: layout.icon.small),
                          child: l),
                      SizedBox(
                        width: paddingToUse.resolve(text.textDirection).left,
                      ),
                    ],
                    Expanded(
                      child: DefaultTextStyle(
                        style:
                            Theme.of(context).textTheme.bodyText1 ?? bodyText1,
                        child: text,
                      ),
                    ),
                  ],
                ),
              ),
              if (!disabled)
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
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.radioKey,
    Key? key,
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Key? radioKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: layout.selectableField.position,
      right: layout.selectableField.position,
      child: Container(
        padding: layout.selectableField.padding,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: layout.selectableField.size,
          height: layout.selectableField.size,
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

class AbiliaRadio<T> extends StatefulWidget {
  const AbiliaRadio({
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
    Key? key,
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
  State createState() => _RadioState<T>();
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
    canvas.drawCircle(center, layout.radio.outerRadius, paint);

    // Inner circle
    if (!position.isDismissed) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(
          center, layout.radio.innerRadius * position.value, paint);
    }
  }
}
