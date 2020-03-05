import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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
          color: AbiliaColors.black[75],
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
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: AbiliaColors.transparantBlack[15],
            ),
            color: active ? AbiliaColors.white : Colors.transparent,
          ),
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
                  child: Icon(
                    AbiliaIcons.navigation_next,
                    size: 32.0,
                    color: AbiliaColors.black[60],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchField extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final Widget leading, label;
  final double heigth, width;
  final bool value;

  const SwitchField({
    Key key,
    this.onChanged,
    this.leading,
    this.label,
    this.heigth = 56,
    this.width,
    this.value = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final switchToggle = Switch(
      value: value,
      onChanged: onChanged,
      key: ObjectKey(key),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged(!switchToggle.value) : null,
        borderRadius: borderRadius,
        child: Ink(
          height: heigth,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: AbiliaColors.transparantBlack[15],
            ),
            color: value ? AbiliaColors.white : Colors.transparent,
          ),
          padding: const EdgeInsets.only(left: 12.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (leading != null) leading,
                  const SizedBox(width: 12),
                  if (label != null) label,
                ],
              ),
              switchToggle,
            ],
          ),
        ),
      ),
    );
  }
}

class RadioField<T> extends StatelessWidget {
  final Widget leading, label;
  final double heigth, width;
  final T value, groupValue;
  final ValueChanged<T> onChanged;

  const RadioField({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.leading,
    this.label,
    this.heigth = 56,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      toggleableActiveColor: AbiliaColors.green,
    );
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: theme,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: borderRadius,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Ink(
                height: heigth,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AbiliaColors.transparantBlack[15],
                  ),
                  color: value == groupValue
                      ? AbiliaColors.white
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    if (leading != null) leading,
                    const SizedBox(width: 12),
                    if (label != null) label,
                  ],
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio(
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
    final theme = Theme.of(context).copyWith(
      toggleableActiveColor: AbiliaColors.green,
    );
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: theme,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Ink(
                height: heigth,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AbiliaColors.transparantBlack[15],
                  ),
                  color: selected ? AbiliaColors.white : Colors.transparent,
                ),
                padding:
                    const EdgeInsets.only(left: 12.0, top: 6.0, right: 24.0),
                child: label,
              ),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: AnimatedSwitcher(
                      duration: 300.milliseconds(),
                      transitionBuilder: (child, animation) =>
                          child is Container
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AbiliaColors.transparantBlack[15],
                                ),
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
