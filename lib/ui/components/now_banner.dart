import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class NowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -4,
      top: -2,
      child: Container(
        decoration:
            BoxDecoration(color: AbiliaColors.red, borderRadius: borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Text(
            'now',
            style: Theme.of(context)
                .textTheme
                .overline
                .copyWith(color: AbiliaColors.white),
          ),
        ),
      ),
    );
  }
}
