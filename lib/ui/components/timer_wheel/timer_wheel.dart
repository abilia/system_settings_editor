import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_config.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_painters.dart';
import 'package:seagull/ui/components/timer_wheel/constants.dart';

enum TimerWheelStyle {
  simplified,
  interactive,
  nonInteractive,
}

class TimerWheel extends StatefulWidget {
  const TimerWheel({
    Key? key,
    required this.style,
    this.timerLengthInMinutes,
    this.secondsLeft,
  })  : assert(
            !(style == TimerWheelStyle.interactive &&
                (timerLengthInMinutes != null || secondsLeft != null)),
            'When style is TimerWheelStyle.interactive, timerLengthInMinutes and secondsLeft will be ignored and should not be set'),
        super(key: key);

  final TimerWheelStyle style;
  final int? timerLengthInMinutes;
  final int? secondsLeft;

  @override
  _TimerWheelState createState() => _TimerWheelState();
}

class _TimerWheelState extends State<TimerWheel> {
  //Range [0..1]
  late double sliderValue = _sliderValueFromSeconds(widget.secondsLeft ?? 0);
  ValueNotifier<int> minutesSelected = ValueNotifier(0);
  int? minutesSelectedOnTapDown;
  bool sliderTemporaryLocked = false;

  @override
  void dispose() {
    minutesSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final config = TimerWheelConfiguration(
        canvasSize: constraints.biggest,
        style: widget.style,
      );

      final Widget stackedWheel = Stack(
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
          ValueListenableBuilder(
            valueListenable: minutesSelected,
            builder: (context, value, child) {
              return CustomPaint(
                size: constraints.biggest,
                painter: TimerWheelForegroundPainter(
                  config: config,
                  secondsLeft: widget.style == TimerWheelStyle.interactive
                      ? minutesSelected.value * secondsInOneMinute
                      : widget.secondsLeft ?? 0,
                ),
              );
            },
          ),
        ],
      );

      if (widget.style != TimerWheelStyle.interactive) {
        return stackedWheel;
      } else {
        return GestureDetector(
          onPanDown: (details) => _onPanDown(details, config),
          onPanUpdate: (details) => _onPanUpdate(details, config),
          onTapUp: _onTapUp,
          child: stackedWheel,
        );
      }
    });
  }

  _onPanDown(DragDownDetails details, TimerWheelConfiguration config) {
    sliderTemporaryLocked = false;
    if (_pointIsOnWheel(details.localPosition, config)) {
      sliderValue = _sliderValueFromPoint(details.localPosition, config);
      minutesSelectedOnTapDown = minutesSelected.value;
    }
  }

  _onPanUpdate(DragUpdateDetails details, TimerWheelConfiguration config) {
    void maybeLockSlider(double value) {
      const margin = 5;

      final isCrossingZeroForwards =
          minutesSelected.value > minutesInOneHour - margin &&
              _minutesFromSliderValue(value) < margin;
      final isCrossingZeroBackwards = minutesSelected.value < margin &&
          _minutesFromSliderValue(value) > minutesInOneHour - margin;

      if (isCrossingZeroForwards || isCrossingZeroBackwards) {
        sliderTemporaryLocked = true;
        _updateSliderValue(isCrossingZeroBackwards ? 0 : 1);
        return;
      }

      if (minutesSelected.value >= minutesInOneHour - margin &&
              _minutesFromSliderValue(value) >= minutesInOneHour - margin ||
          minutesSelected.value <= margin &&
              _minutesFromSliderValue(value) <= margin) {
        sliderTemporaryLocked = false;
      }
    }

    if (_pointIsOnWheel(details.localPosition, config)) {
      final sliderValue = _sliderValueFromPoint(details.localPosition, config);
      maybeLockSlider(sliderValue);
      if (sliderTemporaryLocked) {
        return;
      }
      _updateSliderValue(sliderValue);
    }
  }

  _onTapUp(TapUpDetails details) {
    if (minutesSelectedOnTapDown == minutesSelected.value) {
      int desiredMinutesLeft =
          ((sliderValue * minutesInOneHour) / 5).ceil() * 5;
      assert(desiredMinutesLeft >= 0 && desiredMinutesLeft <= minutesInOneHour,
          'Tried setting timer wheel to invalid time');
      desiredMinutesLeft.clamp(0, minutesInOneHour);
      _updateSliderValue(desiredMinutesLeft / minutesInOneHour);
    }
    minutesSelectedOnTapDown = null;
  }

  void _updateSliderValue(double value) {
    assert(value >= 0 && value <= 1, 'Value not in range [0..1]');
    value.clamp(0, 1);
    final oldMinutesSelected = _minutesFromSliderValue(sliderValue);
    sliderValue = value;
    final newMinutesSelected = _minutesFromSliderValue(sliderValue);
    if (oldMinutesSelected != newMinutesSelected) {
      minutesSelected.value = newMinutesSelected;
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

  // Returns a value in range: [0..60]
  int _minutesFromSliderValue(double value) {
    assert(value >= 0 && value <= 1, 'Given value is out of range [0..1]');
    value.clamp(0, 1);
    return (value * minutesInOneHour).floor();
  }

  // Returns a value in range: [0..1]
  double _sliderValueFromPoint(Offset point, TimerWheelConfiguration config) {
    final deltaX = point.dx - config.centerPoint.dx;
    final deltaY = config.centerPoint.dy - point.dy;
    var angle = atan2(deltaY, deltaX);
    angle = angle - pi / 2;

    if (angle.isNegative) {
      angle = angle + 2 * pi;
    }

    return angle / (2 * pi);
  }

  // Returns a value in range: [0..1]
  double _sliderValueFromSeconds(int seconds) {
    return seconds.clamp(0, secondsInOneHour) / secondsInOneHour;
  }
}
