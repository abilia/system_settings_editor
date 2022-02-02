import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityTopInfo extends StatelessWidget {
  final ActivityDay activityDay;
  final NotificationAlarm? alarm;

  const ActivityTopInfo(
    this.activityDay, {
    Key? key,
    this.alarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alarm = this.alarm;
    if (alarm is NewAlarm && alarm.speech.isNotEmpty) {
      if (alarm is StartAlarm) {
        return _ActivityTopInfo(
          activityDay,
          leading: PlayAlarmSpeechButton(
            alarm: alarm,
          ),
        );
      } else if (alarm is EndAlarm) {
        return _ActivityTopInfo(
          activityDay,
          trailing: PlayAlarmSpeechButton(
            alarm: alarm,
          ),
        );
      }
    }

    final startSpeech = activityDay.activity.extras.startTimeExtraAlarm;
    final endSpeech = activityDay.activity.extras.endTimeExtraAlarm;
    final showStart = startSpeech.isNotEmpty && alarm is! ReminderUnchecked;
    if (showStart || endSpeech.isNotEmpty) {
      return BlocProvider(
        create: (context) => SoundCubit(
          storage: GetIt.I<FileStorage>(),
          userFileCubit: context.read<UserFileCubit>(),
        ),
        child: _ActivityTopInfo(
          activityDay,
          leading: showStart ? PlaySoundButton(sound: startSpeech) : null,
          trailing:
              endSpeech.isNotEmpty ? PlaySoundButton(sound: endSpeech) : null,
        ),
      );
    }
    return _ActivityTopInfo(activityDay);
  }
}

class _ActivityTopInfo extends StatelessWidget {
  const _ActivityTopInfo(
    this.activityDay, {
    Key? key,
    this.leading,
    this.trailing,
  }) : super(key: key);
  final ActivityDay activityDay;
  final Widget? leading, trailing;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final totalWidth = layout.actionButton.size * 2 -
        layout.activityPage.dashSpacing * 4 +
        layout.activityPage.dashWidth;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final timeBoxMaxWidth = (constraints.maxWidth - totalWidth) / 2;
      return BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) {
          return Padding(
            padding: layout.activityPage.timeRowPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leading ?? SizedBox(width: layout.actionButton.size),
                if (activity.fullDay)
                  _TimeBox(
                    occasion: activityDay.day.isDayBefore(now)
                        ? Occasion.past
                        : Occasion.future,
                    text: Translator.of(context).translate.fullDay,
                  )
                else if (!activity.hasEndTime)
                  _TimeBox(
                    text: hourAndMinuteFormat(context)(activityDay.start),
                    occasion: activityDay.start.occasion(now),
                    key: TestKey.startTime,
                  )
                else ...[
                  Expanded(
                    child: Row(
                      children: [
                        const Spacer(),
                        _TimeBox(
                          maxWidth: timeBoxMaxWidth,
                          key: TestKey.startTime,
                          text: hourAndMinuteFormat(context)(activityDay.start),
                          occasion: activityDay.start.occasion(now),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: layout.activityPage.dashSpacing,
                    ),
                    child: SizedBox(
                      width: layout.activityPage.dashWidth,
                      child: Text(
                        '-',
                        style: Theme.of(context).textTheme.headline5,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _TimeBox(
                          maxWidth: timeBoxMaxWidth,
                          key: TestKey.endTime,
                          text: hourAndMinuteFormat(context)(activityDay.end),
                          occasion: activityDay.end.occasion(now),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
                trailing ?? SizedBox(width: layout.actionButton.size),
              ],
            ),
          );
        },
      );
    });
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox(
      {Key? key, required this.text, required Occasion occasion, this.maxWidth})
      : current = occasion == Occasion.current,
        past = occasion == Occasion.past,
        future = occasion == Occasion.future,
        super(key: key);

  final bool current, past, future;
  final String text;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .headline6
        ?.copyWith(color: past ? AbiliaColors.white140 : AbiliaColors.black);
    final boxDecoration = _decoration;
    final maxMaxWidth = layout.activityPage.timeBoxSize.width;
    return Tts.data(
      data: text,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: ActivityInfo.animationDuration,
            padding: layout.activityPage.timeBoxPadding,
            constraints: BoxConstraints(
              minWidth: layout.activityPage.minTimeBoxWidth,
              minHeight: layout.activityPage.timeBoxSize.height,
              maxWidth: min(maxWidth ?? maxMaxWidth, maxMaxWidth),
              maxHeight: layout.activityPage.timeBoxSize.height,
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
            child: CrossOver(
              fallbackHeight: layout.activityPage.timeCrossOverSize.height,
              fallbackWidth: layout.activityPage.timeCrossOverSize.width,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _decoration => current
      ? currentBoxDecoration
      : past
          ? pastDecoration
          : boxDecoration;
}

final pastDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: const Border.fromBorderSide(
    BorderSide(style: BorderStyle.none),
  ),
);

final currentBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(
      color: AbiliaColors.red,
      width: border.top.width,
    ),
  ),
);
