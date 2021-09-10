import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  final double offset;
  final TimepillarState timepillarState;
  final DateTime now;
  static final double timelineHeight = 2.s;
  const Timeline({
    Key? key,
    required this.now,
    required this.width,
    required this.timepillarState,
    this.offset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        duration: transitionDuration,
        top: timeToMidDotPixelDistance(
              now: now,
              dotDistance: timepillarState.dotDistance,
              dotSize: timepillarState.dotSize,
            ) -
            offset +
            timepillarState.topPadding -
            timelineHeight / 2,
        child: Container(
          width: width,
          height: timelineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
      );
}
