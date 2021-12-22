import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_config.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_painters.dart';
import 'package:seagull/ui/components/timer_wheel/constants.dart';

class TimerWheel extends StatefulWidget {
  const TimerWheel.interactive({
    Key? key,
    required this.activeSeconds,
    this.onMinutesSelectedChanged,
  })  : style = TimerWheelStyle.interactive,
        timerLengthInMinutes = null,
        super(key: key);

  const TimerWheel.nonInteractive({
    Key? key,
    required this.activeSeconds,
    this.timerLengthInMinutes,
  })  : style = TimerWheelStyle.nonInteractive,
        onMinutesSelectedChanged = null,
        super(key: key);

  const TimerWheel.simplified({
    Key? key,
    required this.activeSeconds,
    this.timerLengthInMinutes,
  })  : style = TimerWheelStyle.simplified,
        onMinutesSelectedChanged = null,
        super(key: key);

  final TimerWheelStyle style;
  final int activeSeconds;
  final Function(int minutesSelected)? onMinutesSelectedChanged;
  final int? timerLengthInMinutes;

  @override
  _TimerWheelState createState() => _TimerWheelState();
}

class _TimerWheelState extends State<TimerWheel> {
  int? minutesSelectedOnTapDown;
  bool sliderTemporaryLocked = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final config = TimerWheelConfiguration(
        canvasSize: constraints.biggest,
        style: widget.style,
      );

      final Widget timerWheel = Stack(
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: constraints.biggest,
              painter: TimerWheelBackgroundPainter(
                config: config,
                timerLengthInMinutes:
                    widget.timerLengthInMinutes ?? minutesInOneHour,
              ),
            ),
          ),
          CustomPaint(
            size: constraints.biggest,
            painter: TimerWheelForegroundPainter(
              config: config,
              activeSeconds: widget.activeSeconds,
            ),
          ),
        ],
      );

      if (widget.style != TimerWheelStyle.interactive) {
        return timerWheel;
      } else {
        return GestureDetector(
          onPanDown: (details) => _onPanDown(details, config),
          onPanUpdate: (details) => _onPanUpdate(details, config),
          onTapUp: (details) => _onTapUp(details, config),
          child: timerWheel,
        );
      }
    });
  }

  _updateMinutesSelected(int minutes) {
    if (widget.activeSeconds / secondsInOneMinute != minutes) {
      widget.onMinutesSelectedChanged?.call(minutes);
    }
  }

  _onPanDown(DragDownDetails details, TimerWheelConfiguration config) {
    sliderTemporaryLocked = false;
    if (_pointIsOnWheel(details.localPosition, config)) {
      minutesSelectedOnTapDown =
          _minutesFromPoint(details.localPosition, config);
    }
  }

  _onPanUpdate(DragUpdateDetails details, TimerWheelConfiguration config) {
    void maybeLockSlider() {
      const controlMargin = 5;

      final activeMinutes = widget.activeSeconds / secondsInOneMinute;

      final isCrossingZeroForwards =
          activeMinutes > minutesInOneHour - controlMargin &&
              _minutesFromPoint(details.localPosition, config) < controlMargin;
      final isCrossingZeroBackwards = activeMinutes < controlMargin &&
          _minutesFromPoint(details.localPosition, config) >
              minutesInOneHour - controlMargin;

      if (isCrossingZeroForwards || isCrossingZeroBackwards) {
        sliderTemporaryLocked = true;
        _updateMinutesSelected(isCrossingZeroBackwards ? 0 : minutesInOneHour);
        return;
      }

      if (activeMinutes >= minutesInOneHour - controlMargin &&
              _minutesFromPoint(details.localPosition, config) >=
                  minutesInOneHour - controlMargin ||
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

  _onTapUp(TapUpDetails details, TimerWheelConfiguration config) {
    if (minutesSelectedOnTapDown ==
        _minutesFromPoint(details.localPosition, config)) {
      int desiredMinutesLeft =
          (_minutesFromPoint(details.localPosition, config) / 5).ceil() * 5;
      assert(desiredMinutesLeft >= 0 && desiredMinutesLeft <= minutesInOneHour,
          'Tried setting timer wheel to invalid time');
      desiredMinutesLeft.clamp(0, minutesInOneHour);
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
    assert(percentage >= 0 && percentage <= 1,
        'Given value is out of range [0..1]');
    percentage.clamp(0, 1);
    return (percentage * minutesInOneHour).floor();
  }
}
