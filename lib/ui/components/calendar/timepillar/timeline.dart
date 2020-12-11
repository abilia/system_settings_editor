import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  final double offset;
  static const double timelineHeight = 2;
  const Timeline({
    Key key,
    @required this.width,
    this.offset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => AnimatedPositioned(
        duration: transitionDuration,
        child: Container(
          width: width,
          height: timelineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
        top: timeToMidDotPixelDistance(now) -
            offset +
            TimePillarCalendar.topPadding -
            timelineHeight / 2,
      ),
    );
  }
}
