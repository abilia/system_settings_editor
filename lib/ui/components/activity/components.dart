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

  const PickField({
    Key key,
    this.onTap,
    this.leading,
    this.label,
    this.heigth = 56,
    this.active = true,
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
            Icon(AbiliaIcons.navigation_next),
          ],
        ),
      ),
    );
  }
}

class SwitchField extends StatefulWidget {
  final GestureTapCallback onTap;
  final Widget leading, label;
  final double heigth, width;
  final bool startValue;

  const SwitchField({
    Key key,
    this.onTap,
    this.leading,
    this.label,
    this.heigth = 56,
    this.width,
    this.startValue = false,
  }) : super(key: key);

  @override
  _SwitchFieldState createState() => _SwitchFieldState(startValue);
}

class _SwitchFieldState extends State<SwitchField> {
  bool value;

  _SwitchFieldState(this.value);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          value = !value;
        });
        if (widget.onTap != null) widget.onTap();
      },
      borderRadius: borderRadius,
      child: Ink(
        height: 56,
        width: widget.width,
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
                if (widget.leading != null) widget.leading,
                const SizedBox(width: 12),
                if (widget.label != null) widget.label,
              ],
            ),
            Switch(
                value: value,
                onChanged: (v) {
                  setState(() {
                    value = !value;
                  });
                  if (widget.onTap != null) widget.onTap();
                }),
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
      child: Expanded(
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: borderRadius,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Ink(
                height: 56,
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
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio(
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
