import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  final double offset;
  final TimepillarState timepillarState;
  final DateTime now;
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
            layout.timePillar.timeLineHeight / 2,
        child: Container(
          width: width,
          height: layout.timePillar.timeLineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
      );
}
