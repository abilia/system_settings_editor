import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/models/all.dart';

class HeroTitle extends StatelessWidget {
  final DefaultTextStyle child;
  final ActivityDay activityDay;

  const HeroTitle({
    Key key,
    @required this.child,
    @required this.activityDay,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${activityDay.activity.id}${activityDay.day}title',
      // Unecessary when https://github.com/flutter/flutter/issues/36220 is solved
      flightShuttleBuilder: _flightShuttleBuilder,
      child: child,
    );
  }
}

Widget _flightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final from = ((fromHeroContext.widget as Hero).child as DefaultTextStyle);
  final to = ((toHeroContext.widget as Hero).child as DefaultTextStyle);
  final tween = (flightDirection == HeroFlightDirection.pop
          ? TextStyleTween(begin: to.style, end: from.style)
          : TextStyleTween(begin: from.style, end: to.style))
      .animate(animation);
  return Material(
    type: MaterialType.transparency,
    child: DefaultTextStyleTransition(
      child: to.child,
      style: tween,
      softWrap: false,
      overflow: TextOverflow.visible,
    ),
  );
}

class HeroImage extends StatelessWidget {
  final Widget child;
  final ActivityDay activityDay;

  const HeroImage({Key key, this.activityDay, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${activityDay.activity.id}${activityDay.day}image',
      child: child,
    );
  }
}
