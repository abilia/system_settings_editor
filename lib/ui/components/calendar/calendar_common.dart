import 'package:flutter/widgets.dart';
import 'package:seagull/ui/components/calendar/month/month_calendar.dart';
import 'package:seagull/ui/themes/all.dart';
import 'package:seagull/utils/scale_util.dart';

class FullDayStack extends StatelessWidget {
  const FullDayStack({
    Key? key,
    required this.numberOfActivities,
    this.width,
    this.height,
  }) : super(key: key);

  final int numberOfActivities;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AbiliaColors.white,
      borderRadius: MonthDayView.monthDayborderRadius,
      border: border,
    );
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.s, left: 4.s),
          width: width ?? 2.s,
          height: height ?? 2.s,
          decoration: decoration,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4.s, right: 4.s),
          decoration: decoration,
          width: width ?? 2.s,
          height: height ?? 2.s,
          child: Center(
            child: Text('+$numberOfActivities'),
          ),
        ),
      ],
    );
  }
}
