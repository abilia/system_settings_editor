import 'package:seagull/ui/all.dart';

class Timeline extends StatelessWidget {
  final double width, top;

  const Timeline({
    required this.width,
    this.top = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        duration: transitionDuration,
        top: top,
        child: Container(
          width: width,
          height: layout.timepillar.timeLineHeight,
          decoration: const BoxDecoration(color: AbiliaColors.red),
        ),
      );
}
