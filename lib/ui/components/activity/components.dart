import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/theme.dart';

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
    return InkWell(
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
            if (showTrailingArrow)
              Icon(
                AbiliaIcons.navigation_next,
                size: 32.0,
                color: AbiliaColors.black[60],
              ),
          ],
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
    return InkWell(
      onTap: onChanged != null ? () => onChanged(!switchToggle.value) : null,
      borderRadius: borderRadius,
      child: Ink(
        height: 56,
        width: width,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: AbiliaColors.transparantBlack[15],
          ),
          color: value ? AbiliaColors.white : Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
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
    return Theme(
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
              padding: const EdgeInsets.all(12),
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
    );
  }
}
