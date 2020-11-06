import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/ui/all.dart';

class HourLines extends StatelessWidget {
  const HourLines({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          24,
          (_) => Container(
            height: hourHeigt,
            child: const DottedLine(
              dashColor: AbiliaColors.white135,
            ),
          ),
        ),
      );
}
