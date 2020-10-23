import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class InfoButton extends StatelessWidget {
  final GestureTapCallback onTap;

  const InfoButton({
    Key key,
    this.onTap,
  }) : super(key: key);

  static const radius = BorderRadius.all(Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: TestKey.ttsInfoButton,
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: 40,
        height: 40,
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
