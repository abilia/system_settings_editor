import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/ui/components/timer/timer_wheel/timer_wheel_config.dart';
import 'package:memoplanner/ui/components/timer/timer_wheel/timer_wheel_painters.dart';
import 'package:memoplanner/ui/components/timer/timer_wheel/timer_wheel_styles.dart';
import 'package:text_to_speech/text_to_speech.dart';

class TimerWheel extends StatefulWidget {
  const TimerWheel.interactive({
    required int lengthInSeconds,
    this.onMinutesSelectedChanged,
    super.key,
  })  : activeSeconds = lengthInSeconds,
        finished = false,
        style = TimerWheelStyle.interactive,
        lengthInMinutes = null,
        paused = false,
        isPast = false,
        showTimeText = false;

  const TimerWheel.nonInteractive({
    required int secondsLeft,
    this.lengthInMinutes,
    this.paused = false,
    super.key,
  })  : assert(secondsLeft >= 0, 'seconds cannot be negative'),
        isPast = secondsLeft == 0 && !paused,
        activeSeconds = secondsLeft,
        finished = false,
        style = TimerWheelStyle.nonInteractive,
        onMinutesSelectedChanged = null,
        showTimeText = true;

  const TimerWheel.simplified({
    required int secondsLeft,
    this.lengthInMinutes,
    this.paused = false,
    super.key,
  })  : assert(secondsLeft >= 0, 'seconds cannot be negative'),
        isPast = secondsLeft == 0 && !paused,
        activeSeconds = secondsLeft,
        finished = false,
        style = TimerWheelStyle.simplified,
        onMinutesSelectedChanged = null,
        showTimeText = false;

  const TimerWheel.finished({
    super.key,
    int length = 0,
    bool withPaint = false,
  })  : isPast = false,
        paused = false,
        activeSeconds = withPaint ? length * 60 : 0,
        finished = true,
        lengthInMinutes = length,
        style = TimerWheelStyle.nonInteractive,
        onMinutesSelectedChanged = null,
        showTimeText = true;

  final TimerWheelStyle style;
  final int activeSeconds;
  final Function(int minutesSelected)? onMinutesSelectedChanged;
  final int? lengthInMinutes;
  final bool paused;
  final bool isPast;
  final bool finished;
  final bool showTimeText;

  @override
  State createState() => _TimerWheelState();
}

class _TimerWheelState extends State<TimerWheel> {
  static const int _intervalLength = 5;
  // _margin is used to to avoid clicking close to the slider thumb.
  // _upperLimit is used to to avoid clicking on 60 minutes and round the value to 0 minutes.
  static const _margin = 2;
  static const int _upperLimit = Duration.secondsPerMinute - _margin;

  bool _sliderTemporaryLocked = false;
  late bool _textToSpeech;
  Offset? _longPressUpdatePosition;
  Timer? _longPressTimer;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _textToSpeech = context.watch<SpeechSettingsCubit>().state.textToSpeech;
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
          return GestureDetector(
            onTapDown: (details) => _onTapDown(details.localPosition, config),
            onPanUpdate: (details) =>
                _onPanUpdate(details.localPosition, config),
            onPanCancel: _cancelLongPressTimer,
            onPanEnd: (_) => _cancelLongPressTimer(),
            child: timerWheel,
          );
        }
      },
    );
  }

  void _startLongPressTtsTimer(
    Offset downPosition,
    TimerWheelConfiguration config,
  ) {
    if (!_textToSpeech || !_pointIsOnNumberWheel(downPosition, config)) return;

    _cancelLongPressTimer();
    _longPressTimer = Timer(kLongPressTimeout, () async {
      final lastPosition = _longPressUpdatePosition;
      if (lastPosition != null) {
        final distance = (downPosition - lastPosition).distance;
        if (distance > kTouchSlop) return;
      }

      final minutes = _minutesFromPoint(downPosition, config);
      final fiveMinInterval =
          ((minutes % _upperLimit) / _intervalLength).round() * _intervalLength;
      final minute = minutes % _intervalLength;
      if (minute == 0 || minute == _intervalLength - 1) {
        await GetIt.I<TtsHandler>().speak(
          '$fiveMinInterval ${Lt.of(context).minutes}',
        );
      }
    });
  }

  void _updateMinutesSelected(int minutes) {
    if (widget.activeSeconds / Duration.secondsPerMinute != minutes) {
      widget.onMinutesSelectedChanged?.call(minutes);
    }
  }

  void _cancelLongPressTimer() {
    _longPressUpdatePosition = null;
    _longPressTimer?.cancel();
  }

  void _onTapDown(Offset downPosition, TimerWheelConfiguration config) {
    _startLongPressTtsTimer(downPosition, config);
    if (!_pointIsOnWheel(downPosition, config)) return;

    _sliderTemporaryLocked = false;
    final selectedMinute = _minutesFromPoint(downPosition, config);

    if (_minutesWithinSliderThumb(selectedMinute)) return;

    final desiredMinutesLeft =
        (selectedMinute / _intervalLength).ceil() * _intervalLength;
    assert(
      desiredMinutesLeft >= 0 && desiredMinutesLeft <= Duration.minutesPerHour,
      'Tried setting timer wheel to invalid time',
    );
    desiredMinutesLeft.clamp(0, Duration.minutesPerHour);
    _updateMinutesSelected(desiredMinutesLeft);
  }

  void _onPanUpdate(Offset updatePosition, TimerWheelConfiguration config) {
    _longPressUpdatePosition = updatePosition;

    void maybeLockSlider() {
      const controlMargin = _intervalLength;

      final activeMinutes = widget.activeSeconds / Duration.secondsPerMinute;

      final isCrossingZeroForwards =
          activeMinutes > Duration.minutesPerHour - controlMargin &&
              _minutesFromPoint(updatePosition, config) < controlMargin;
      final isCrossingZeroBackwards = activeMinutes < controlMargin &&
          _minutesFromPoint(updatePosition, config) >
              Duration.minutesPerHour - controlMargin;

      if (isCrossingZeroForwards || isCrossingZeroBackwards) {
        _sliderTemporaryLocked = true;
        _updateMinutesSelected(
          isCrossingZeroBackwards ? 0 : Duration.minutesPerHour,
        );
        return;
      }

      if (activeMinutes >= Duration.minutesPerHour - controlMargin &&
              _minutesFromPoint(updatePosition, config) >=
                  Duration.minutesPerHour - controlMargin ||
          activeMinutes <= controlMargin &&
              _minutesFromPoint(updatePosition, config) <= controlMargin) {
        _sliderTemporaryLocked = false;
      }
    }

    if (_pointIsOnWheel(updatePosition, config)) {
      maybeLockSlider();
      if (!_sliderTemporaryLocked) {
        final activeMinutes = _minutesFromPoint(updatePosition, config);
        _updateMinutesSelected(activeMinutes);
      }
    }
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

  bool _minutesWithinSliderThumb(int minutes) {
    final currentMinutes = widget.activeSeconds ~/ Duration.secondsPerMinute;
    final minutesWithUpperLimit = minutes % _upperLimit;
    final diff = (currentMinutes - minutesWithUpperLimit).abs();
    return diff <= _margin;
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
    return (percentage * Duration.minutesPerHour).round();
  }
}
