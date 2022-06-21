import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/settings/settings_cubit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/components/timer/timer_wheel/timer_wheel_config.dart';
import 'package:seagull/ui/components/timer/timer_wheel/timer_wheel_painters.dart';
import 'package:seagull/ui/components/timer/timer_wheel/timer_wheel_styles.dart';

class TimerWheel extends StatefulWidget {
  const TimerWheel.interactive({
    Key? key,
    required int lengthInSeconds,
    this.onMinutesSelectedChanged,
  })  : activeSeconds = lengthInSeconds,
        finished = false,
        style = TimerWheelStyle.interactive,
        lengthInMinutes = null,
        paused = false,
        isPast = false,
        showTimeText = false,
        super(key: key);

  const TimerWheel.nonInteractive({
    Key? key,
    required int secondsLeft,
    this.lengthInMinutes,
    this.paused = false,
  })  : assert(secondsLeft >= 0, 'seconds cannot be negative'),
        isPast = secondsLeft == 0 && !paused,
        activeSeconds = secondsLeft,
        finished = false,
        style = TimerWheelStyle.nonInteractive,
        onMinutesSelectedChanged = null,
        showTimeText = true,
        super(key: key);

  const TimerWheel.simplified({
    Key? key,
    required int secondsLeft,
    this.lengthInMinutes,
    this.paused = false,
  })  : assert(secondsLeft >= 0, 'seconds cannot be negative'),
        isPast = secondsLeft == 0 && !paused,
        activeSeconds = secondsLeft,
        finished = false,
        style = TimerWheelStyle.simplified,
        onMinutesSelectedChanged = null,
        showTimeText = false,
        super(key: key);

  const TimerWheel.finished({
    Key? key,
    int length = 0,
    bool withPaint = false,
  })  : isPast = false,
        paused = false,
        activeSeconds = withPaint ? length * 60 : 0,
        finished = true,
        lengthInMinutes = length,
        style = TimerWheelStyle.nonInteractive,
        onMinutesSelectedChanged = null,
        showTimeText = true,
        super(key: key);

  final TimerWheelStyle style;
  final int activeSeconds;
  final Function(int minutesSelected)? onMinutesSelectedChanged;
  final int? lengthInMinutes;
  final bool paused;
  final bool isPast;
  final bool finished;
  final bool showTimeText;

  @override
  _TimerWheelState createState() => _TimerWheelState();
}

class _TimerWheelState extends State<TimerWheel> {
  int? minutesSelectedOnTapDown;
  bool sliderTemporaryLocked = false;
  final int _intervalLength = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = TimerWheelConfiguration(
          canvasSize: constraints.biggest,
          style: widget.style,
          paused: widget.paused,
          isPast: widget.isPast,
        );

        final Widget timerWheel = Stack(
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: constraints.biggest,
                painter: TimerWheelBackgroundPainter(
                  config: config,
                  lengthInMinutes:
                      widget.lengthInMinutes ?? Duration.minutesPerHour,
                ),
              ),
            ),
            CustomPaint(
              size: constraints.biggest,
              painter: TimerWheelForegroundPainter(
                config: config,
                activeSeconds: widget.activeSeconds,
                finished: widget.finished,
                showTimeText: widget.showTimeText,
              ),
            ),
          ],
        );

        if (widget.style != TimerWheelStyle.interactive) {
          return timerWheel;
        } else {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) => GestureDetector(
              onPanDown: (details) => _onPanDown(details, config),
              onPanUpdate: (details) => _onPanUpdate(details, config),
              onTapUp: (details) => _onTapUp(details, config),
              onLongPressStart: (details) => settingsState.textToSpeech
                  ? _playTtsOnNumbers(details, config)
                  : () {},
              child: timerWheel,
            ),
          );
        }
      },
    );
  }

  void _playTtsOnNumbers(
    LongPressStartDetails details,
    TimerWheelConfiguration config,
  ) {
    if (_pointIsOnNumberWheel(details.localPosition, config)) {
      final minutes = _minutesFromPoint(details.localPosition, config);
      // rounding by 58 to skip '60' minutes
      final fiveMinInterval =
          ((minutes % 58) / _intervalLength).round() * _intervalLength;
      final minute = minutes % _intervalLength;
      if (minute < 1 || minute > 3) {
        GetIt.I<TtsInterface>().speak(
          '$fiveMinInterval ${Translator.of(context).translate.minutes}',
        );
      }
    }
  }

  void _updateMinutesSelected(int minutes) {
    if (widget.activeSeconds / Duration.secondsPerMinute != minutes) {
      widget.onMinutesSelectedChanged?.call(minutes);
    }
  }

  void _onPanDown(DragDownDetails details, TimerWheelConfiguration config) {
    sliderTemporaryLocked = false;
    if (_pointIsOnWheel(details.localPosition, config)) {
      minutesSelectedOnTapDown =
          _minutesFromPoint(details.localPosition, config);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, TimerWheelConfiguration config) {
    void maybeLockSlider() {
      const controlMargin = 5;

      final activeMinutes = widget.activeSeconds / Duration.secondsPerMinute;

      final isCrossingZeroForwards =
          activeMinutes > Duration.minutesPerHour - controlMargin &&
              _minutesFromPoint(details.localPosition, config) < controlMargin;
      final isCrossingZeroBackwards = activeMinutes < controlMargin &&
          _minutesFromPoint(details.localPosition, config) >
              Duration.minutesPerHour - controlMargin;

      if (isCrossingZeroForwards || isCrossingZeroBackwards) {
        sliderTemporaryLocked = true;
        _updateMinutesSelected(
          isCrossingZeroBackwards ? 0 : Duration.minutesPerHour,
        );
        return;
      }

      if (activeMinutes >= Duration.minutesPerHour - controlMargin &&
              _minutesFromPoint(details.localPosition, config) >=
                  Duration.minutesPerHour - controlMargin ||
          activeMinutes <= controlMargin &&
              _minutesFromPoint(details.localPosition, config) <=
                  controlMargin) {
        sliderTemporaryLocked = false;
      }
    }

    if (_pointIsOnWheel(details.localPosition, config)) {
      maybeLockSlider();
      if (!sliderTemporaryLocked) {
        final activeMinutes = _minutesFromPoint(details.localPosition, config);
        _updateMinutesSelected(activeMinutes);
      }
    }
  }

  void _onTapUp(TapUpDetails details, TimerWheelConfiguration config) {
    if (minutesSelectedOnTapDown ==
        _minutesFromPoint(details.localPosition, config)) {
      int desiredMinutesLeft =
          (_minutesFromPoint(details.localPosition, config) / 5).ceil() * 5;
      assert(
        desiredMinutesLeft >= 0 &&
            desiredMinutesLeft <= Duration.minutesPerHour,
        'Tried setting timer wheel to invalid time',
      );
      desiredMinutesLeft.clamp(0, Duration.minutesPerHour);
      _updateMinutesSelected(desiredMinutesLeft);
    }
    minutesSelectedOnTapDown = null;
  }

  bool _pointIsOnWheel(Offset point, TimerWheelConfiguration config) {
    final distanceFromCenter = sqrt(
      pow((point.dx - config.centerPoint.dx), 2) +
          pow((point.dy - config.centerPoint.dy), 2),
    );

    return distanceFromCenter <= config.outerCircleDiameter / 2 &&
        distanceFromCenter >= config.innerCircleDiameter / 2;
  }

  bool _pointIsOnNumberWheel(Offset point, TimerWheelConfiguration config) {
    final distanceFromCenter = sqrt(
      pow((point.dx - config.centerPoint.dx), 2) +
          pow((point.dy - config.centerPoint.dy), 2),
    );

    return distanceFromCenter <= config.maxSize / 2 &&
        distanceFromCenter >= config.outerCircleDiameter / 2;
  }

  // Returns a value in range: [0..60]
  int _minutesFromPoint(Offset point, TimerWheelConfiguration config) {
    final deltaX = point.dx - config.centerPoint.dx;
    final deltaY = config.centerPoint.dy - point.dy;
    var angle = atan2(deltaY, deltaX);
    angle = angle - pi / 2;

    if (angle.isNegative) {
      angle = angle + 2 * pi;
    }

    final percentage = angle / (2 * pi);
    assert(
      percentage >= 0 && percentage <= 1,
      'Given value is out of range [0..1]',
    );
    percentage.clamp(0, 1);
    return (percentage * Duration.minutesPerHour).floor();
  }
}
