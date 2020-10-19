import 'package:flutter/material.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class SwitchField extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final Widget leading;
  final Text text;
  final double heigth, width;
  final bool value;
  final Decoration decoration;

  const SwitchField({
    Key key,
    @required this.text,
    this.onChanged,
    this.leading,
    this.heigth = 56,
    this.width,
    this.value = false,
    this.decoration = whiteBoxDecoration,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final switchToggle = Switch(
      value: value,
      onChanged: onChanged,
      key: ObjectKey(key),
    );
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data,
        toggled: value,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onChanged != null ? () => onChanged(!switchToggle.value) : null,
          borderRadius: borderRadius,
          child: Container(
            height: heigth,
            width: width,
            decoration: onChanged == null ? boxDecoration : decoration,
            padding: const EdgeInsets.only(left: 12.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (leading != null) leading,
                    const SizedBox(width: 12),
                    text,
                  ],
                ),
                switchToggle,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
