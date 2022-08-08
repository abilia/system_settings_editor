import 'package:dotted_line/dotted_line.dart';
import 'package:seagull/ui/all.dart';

class HourLines extends StatelessWidget {
  final int numberOfLines;
  final double hourHeight;
  const HourLines({
    required this.hourHeight,
    this.numberOfLines = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          numberOfLines,
          (_) => SizedBox(
            height: hourHeight,
            child: const DottedLine(
              dashColor: AbiliaColors.white135,
            ),
          ),
        ),
      );
}
