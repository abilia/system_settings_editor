import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  final double offset;
  final TimepillarMeasures measures;
  final DateTime now;
  const Timeline({
    Key? key,
    required this.now,
    required this.width,
    required this.measures,
    this.offset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        duration: transitionDuration,
        top: timeToMidDotPixelDistance(
              now: now,
              dotDistance: measures.dotDistance,
              dotSize: measures.dotSize,
            ) -
            offset +
            measures.topPadding -
            layout.timePillar.timeLineHeight / 2,
        child: Container(
          width: width,
          height: layout.timePillar.timeLineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
      );
}
