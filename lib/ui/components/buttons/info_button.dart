// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class InfoButton extends StatelessWidget {
  final GestureTapCallback onTap;

  const InfoButton({
    Key key,
    this.onTap,
  }) : super(key: key);

  static final radius = BorderRadius.all(Radius.circular(24.s));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: 40.s,
        height: 40.s,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.fromBorderSide(
            BorderSide(
              color: AbiliaColors.transparentBlack30,
            ),
          ),
          color: AbiliaColors.transparentBlack20,
        ),
        child: Icon(
          AbiliaIcons.handi_info,
          size: smallIconSize,
        ),
      ),
    );
  }
}
