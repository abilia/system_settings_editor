import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityTopInfo extends StatelessWidget {
  final NotificationAlarm? alarm;
  final bool fullScreenAlarm;
  const ActivityTopInfo(
    this.activityDay, {
    Key? key,
    this.alarm,
    this.fullScreenAlarm = false,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final day = activityDay.day;
    final a = alarm;
    final startSpeech = a == null
        ? StartAlarm.from(activityDay).speech
        : a is StartAlarm
            ? a.speech
            : null;
    final endSpeech = a == null
        ? EndAlarm.from(activityDay).speech
        : a is EndAlarm
            ? a.speech
            : null;
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) {
        return Padding(
          padding: EdgeInsets.only(top: 4.s, bottom: 8.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a != null &&
                  a is StartAlarm &&
                  startSpeech != null &&
                  startSpeech.isNotEmpty)
                PlayAlarmSpeechButton(
                  alarm: a,
                  fullScreenAlarm: fullScreenAlarm,
                )
              else if (startSpeech != null && startSpeech.isNotEmpty)
                PlaySpeechButton(
                  speech: startSpeech,
                )
              else
                SizedBox(
                  width: 48.s,
                ),
              if (activity.fullDay)
                _TimeBox(
                  occasion:
                      day.isDayBefore(now) ? Occasion.past : Occasion.future,
                  text: Translator.of(context).translate.fullDay,
                )
              else if (!activity.hasEndTime)
                _timeText(
                  context,
                  date: activityDay.start,
                  now: now,
                  key: TestKey.startTime,
                )
              else ...[
                Expanded(
                  child: Row(
                    children: [
                      Spacer(),
                      _timeText(
                        context,
                        date: activityDay.start,
                        now: now,
                        key: TestKey.startTime,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.s),
                  child:
                      Text('-', style: Theme.of(context).textTheme.headline5),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _timeText(
                        context,
                        date: activityDay.end,
                        now: now,
                        key: TestKey.endTime,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ],
              if (a != null &&
                  a is EndAlarm &&
                  endSpeech != null &&
                  endSpeech.isNotEmpty)
                PlayAlarmSpeechButton(
                  alarm: a,
                  fullScreenAlarm: fullScreenAlarm,
                )
              else if (endSpeech != null && endSpeech.isNotEmpty)
                PlaySpeechButton(
                  speech: endSpeech,
                )
              else
                SizedBox(
                  width: 48.s,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeText(
    BuildContext context, {
    required DateTime date,
    required DateTime now,
    required Key key,
  }) =>
      _TimeBox(
        key: key,
        text: hourAndMinuteFormat(context)(date),
        occasion: date.occasion(now),
      );
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    Key? key,
    required this.text,
    required Occasion occasion,
  })  : current = occasion == Occasion.current,
        past = occasion == Occasion.past,
        future = occasion == Occasion.future,
        super(key: key);

  final bool current, past, future;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .headline6
        ?.copyWith(color: past ? AbiliaColors.white140 : AbiliaColors.black);
    final boxDecoration = _decoration;
    return Tts.data(
      data: text,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: ActivityInfo.animationDuration,
            padding: EdgeInsets.all(8.s),
            constraints: BoxConstraints(
              minWidth: 92.0.s,
              minHeight: 52.0.s,
              maxWidth: 102.s,
              maxHeight: 52.0.s,
            ),
            decoration: boxDecoration,
            child: Center(
              child: AutoSizeText(
                text,
                style: textStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          AnimatedOpacity(
              opacity: past ? 1.0 : 0.0,
              duration: ActivityInfo.animationDuration,
              child: CrossOver(fallbackHeight: 38.s, fallbackWidth: 64.s)),
        ],
      ),
    );
  }

  BoxDecoration get _decoration => current
      ? currentBoxDecoration
      : past
          ? pastDecration
          : boxDecoration;
}

final pastDecration = BoxDecoration(
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(style: BorderStyle.none, width: 2.0.s),
  ),
);
