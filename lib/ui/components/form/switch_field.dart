import 'package:flutter/material.dart';
import 'package:seagull/ui/theme.dart';

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
          decoration: value && onChanged != null
              ? whiteBoxDecoration
              : borderDecoration,
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
