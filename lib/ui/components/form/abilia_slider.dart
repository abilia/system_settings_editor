import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class AbiliaSlider extends StatelessWidget {
  final ValueChanged<double>? onChanged;
  final Widget? leading;
  final double? heigth, width;
  final double value;
  static final defaultHeight = 56.s;

  const AbiliaSlider({
    Key? key,
    this.onChanged,
    this.leading,
    this.heigth,
    this.width,
    this.value = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final onChanged = this.onChanged;
    return Container(
      height: heigth ?? defaultHeight,
      width: width,
      decoration: whiteBoxDecoration,
      padding: EdgeInsets.only(left: 12.0.s, right: 4.0.s),
      child: Row(
        children: <Widget>[
          if (leading != null) leading,
          Expanded(
            child: Slider(
              onChanged: onChanged,
              value: value,
            ),
          ),
        ],
      ),
    );
  }
}
