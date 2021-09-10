import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TimeRow extends StatelessWidget {
  const TimeRow(this.activityDay, {Key? key}) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final day = activityDay.day;
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) {
        return Padding(
          padding: EdgeInsets.only(top: 4.s, bottom: 8.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activity.extras.startTimeExtraAlarm != AbiliaFile.empty)
                _playSpeechButton(context, activity.extras.startTimeExtraAlarm),
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
              if (activity.extras.endTimeExtraAlarm != AbiliaFile.empty)
                _playSpeechButton(context, activity.extras.endTimeExtraAlarm),
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

  Widget _playSpeechButton(BuildContext context, AbiliaFile soundToPlay) {
    return BlocProvider(
      create: (context) => SoundCubit(),
      child: BlocBuilder<UserFileBloc, UserFileState>(
        builder: (context, state) {
          return PlaySoundButton(
            sound: context.read<UserFileBloc>().state.getFile(
                  soundToPlay,
                  GetIt.I<FileStorage>(),
                ),
          );
        },
      ),
    );
  }
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
            padding: _padding,
            constraints: BoxConstraints(minWidth: 92.0.s, minHeight: 52.0.s),
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

  EdgeInsets get _padding =>
      EdgeInsets.fromLTRB(21.0.s, 14.0.s, 20.0.s, 14.0.s) +
      (future ? EdgeInsets.all(1.0.s) : EdgeInsets.zero);
}

final pastDecration = BoxDecoration(
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(style: BorderStyle.none, width: 2.0.s),
  ),
);
