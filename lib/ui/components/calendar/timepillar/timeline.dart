import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  final double offset;
  static final double timelineHeight = 2.s;
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
        top: timeToMidDotPixelDistance(
                now, context.read<TimepillarBloc>().state) -
            offset +
            TimePillarCalendar.topPadding -
            timelineHeight / 2,
        child: Container(
          width: width,
          height: timelineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
      ),
    );
  }
}
