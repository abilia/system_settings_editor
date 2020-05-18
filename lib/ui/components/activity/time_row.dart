import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/activity/timeformat.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class TimeRow extends StatelessWidget {
  const TimeRow({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  final Activity activity;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) {
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activity.fullDay)
                _TimeBox(
                  occasion:
                      day.isDayBefore(now) ? Occasion.past : Occasion.future,
                  text: Translator.of(context).translate.fullDay,
                )
              else if (!activity.hasEndTime)
                _timeText(context, date: activity.startClock(day), now: now)
              else ...[
                Expanded(
                  child: Row(
                    children: [
                      Spacer(),
                      _timeText(context,
                          date: activity.startClock(day), now: now),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child:
                      Text('-', style: Theme.of(context).textTheme.headline5),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _timeText(
                        context,
                        date: activity.endClock(day),
                        now: now,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _timeText(
    BuildContext context, {
    @required DateTime date,
    @required DateTime now,
  }) =>
      _TimeBox(
          text: hourAndMinuteFormat(context)(date),
          occasion: date.occasion(now));
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    Key key,
    @required this.text,
    @required Occasion occasion,
  })  : current = occasion == Occasion.current,
        past = occasion == Occasion.past,
        future = occasion == Occasion.future,
        super(key: key);

  final bool current, past, future;
  final String text;

  @override
  Widget build(BuildContext context) {
    // var past = false, current = true;
    final textStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: past ? AbiliaColors.white140 : AbiliaColors.black);
    final boxDecoration = _decoration;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: ActivityInfo.animationDuration,
          padding: _padding,
          constraints: const BoxConstraints(minWidth: 92.0, minHeight: 52.0),
          decoration: boxDecoration,
          child: Center(
            child: Text(
              text,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AnimatedOpacity(
            opacity: past ? 1.0 : 0.0,
            duration: ActivityInfo.animationDuration,
            child: const CrossOver(fallbackHeight: 38, fallbackWidth: 64)),
      ],
    );
  }

  BoxDecoration get _decoration =>
      current ? currentBoxDecoration : past ? pastDecration : borderDecoration;
  EdgeInsets get _padding => const EdgeInsets.fromLTRB(21.0, 14.0, 20.0, 14.0)
      .add(future ? const EdgeInsets.all(1.0) : EdgeInsets.zero);
}

const pastDecration = BoxDecoration(
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(style: BorderStyle.none, width: 2.0),
  ),
);
