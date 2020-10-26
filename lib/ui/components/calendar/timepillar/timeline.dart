import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class Timeline extends StatelessWidget {
  final double width;
  const Timeline({
    Key key,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => AnimatedPositioned(
        duration: transitionDuration,
        child: Container(
          width: width,
          height: 2,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
        top: timeToMidDotPixelDistance(now),
      ),
    );
  }
}
