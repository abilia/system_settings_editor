// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityOccasionDecoration extends StatelessWidget {
  final Widget child;
  final EdgeInsets crossOverPadding;
  final Color color;
  final ActivityOccasion activityOccasion;
  const ActivityOccasionDecoration({
    Key key,
    @required this.child,
    @required this.activityOccasion,
    this.crossOverPadding = EdgeInsets.zero,
    this.color = const Color(0xFF000000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inactive = activityOccasion.isPast || activityOccasion.isSignedOff;
    return Stack(
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 400),
          opacity: inactive ? 0.5 : 1.0,
          child: child,
        ),
        if (activityOccasion.isSignedOff)
          CheckMark()
        else if (activityOccasion.isPast)
          Padding(
            padding: crossOverPadding,
            child: CrossOver(
              color: color,
            ),
          ),
      ],
    );
  }
}
