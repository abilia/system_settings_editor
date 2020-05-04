import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/activity/timeformat.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class ActivityTimeRange extends StatelessWidget {
  const ActivityTimeRange({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  final Activity activity;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !activity.hasEndTime
              ? [
                  _TimeText(
                    date: activity.startClock(day),
                    now: now,
                  ),
                ]
              : [
                  Expanded(
                    child: Row(
                      children: [
                        Spacer(),
                        _TimeText(
                          date: activity.startClock(day),
                          now: now,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child:
                        Text('-', style: Theme.of(context).textTheme.headline),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _TimeText(
                          date: activity.endClock(day),
                          now: now,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

class _TimeText extends StatelessWidget {
  _TimeText({
    Key key,
    @required this.date,
    @required DateTime now,
  })  : occasion = date.occasion(now),
        super(key: key);

  final DateTime date;
  final Occasion occasion;
  bool get past => occasion == Occasion.past;
  bool get future => occasion == Occasion.future;
  bool get current => occasion == Occasion.current;

  @override
  Widget build(BuildContext context) {
    final timeFormat = hourAndMinuteFormat(context);
    final textStyle = Theme.of(context)
        .textTheme
        .title
        .copyWith(color: past ? AbiliaColors.white[140] : AbiliaColors.black);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      constraints: const BoxConstraints(minWidth: 92.0, minHeight: 52.0),
      decoration: _getBoxDecoration(),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              timeFormat(date),
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            if (past) CrossOver(fallbackHeight: 38, fallbackWidth: 64),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() => current
      ? BoxDecoration(
          color: AbiliaColors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: AbiliaColors.red,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        )
      : BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: AbiliaColors.white[120],
            width: 1.0,
            style: past ? BorderStyle.none : BorderStyle.solid,
          ),
        );
}
