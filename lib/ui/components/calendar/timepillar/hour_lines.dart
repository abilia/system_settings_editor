import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class HourLines extends StatelessWidget {
  final numberOfLines;
  const HourLines({
    Key key,
    this.numberOfLines = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          numberOfLines,
          (_) => Container(
            height: hourHeigt,
            child: const DottedLine(
              dashColor: AbiliaColors.white135,
            ),
          ),
        ),
      );
}
