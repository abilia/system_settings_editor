import 'package:flutter/widgets.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/calendar/timepillar/all.dart';

class Timeline extends StatelessWidget {
  final DateTime now;
  final double width;
  const Timeline({
    Key key,
    @required this.now,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: transitionDuration,
      child: Container(
        width: width,
        height: 2,
        decoration: BoxDecoration(color: AbiliaColors.red),
      ),
      top: timeToPixelDistance(now),
    );
  }
}
