// @dart=2.9

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/ui/all.dart';

class HourLines extends StatelessWidget {
  final int numberOfLines;
  final double hourHeight;
  const HourLines({
    Key key,
    this.numberOfLines = 24,
    @required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          numberOfLines,
          (_) => Container(
            height: hourHeight,
            child: const DottedLine(
              dashColor: AbiliaColors.white135,
            ),
          ),
        ),
      );
}
