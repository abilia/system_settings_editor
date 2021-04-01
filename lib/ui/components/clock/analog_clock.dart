library flutter_analog_clock;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:intl/intl.dart';

import 'clock_painter.dart';

// A modified copy of: https://github.com/conghaonet/flutter_analog_clock
class AnalogClock extends StatelessWidget {
  final VoidCallback onPressed;
  final DateTime dateTime;
  final Color dialPlateColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color centerPointColor;
  final double centerPointRadius;
  final bool showBorder;
  final bool showMinuteHand;
  final bool showNumber;
  final double borderWidth;
  final double hourNumberScale;
  final List<String> hourNumbers;
  final bool isLive;
  final double width;
  final double height;
  final double fontSize;
  final double minuteHandLength;
  final double hourHandLength;
  final BoxDecoration decoration;
  final Widget child;

  const AnalogClock({
    this.dateTime,
    this.dialPlateColor = AbiliaColors.white,
    this.hourHandColor = AbiliaColors.black,
    this.minuteHandColor = AbiliaColors.black,
    this.numberColor = AbiliaColors.black,
    this.borderColor = AbiliaColors.black,
    this.centerPointColor = AbiliaColors.black,
    this.centerPointRadius,
    this.showBorder = true,
    this.showMinuteHand = true,
    this.showNumber = true,
    this.borderWidth,
    this.hourNumberScale = 1.0,
    this.fontSize,
    this.hourNumbers = ClockPainter.defaultHourNumbers,
    this.isLive = true,
    this.width = double.infinity,
    this.height = double.infinity,
    this.decoration = const BoxDecoration(),
    this.hourHandLength,
    this.minuteHandLength,
    this.child,
    this.onPressed,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).toLanguageTag();
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) => GestureDetector(
          onTap: onPressed,
          child: Tts(
            data:
                memoSettingsState.timepillarHourClockType == HourClockType.use12
                    ? DateFormat('hh:mm a', language).format(time)
                    : DateFormat('HH:mm', language).format(time),
            child: Container(
              width: width,
              height: height,
              decoration: decoration,
              child: CustomPaint(
                painter: ClockPainter(
                  time,
                  dialPlateColor: dialPlateColor,
                  hourHandColor: hourHandColor,
                  minuteHandColor: minuteHandColor,
                  numberColor: numberColor,
                  borderColor: borderColor,
                  centerPointColor: centerPointColor,
                  centerPointRadius: centerPointRadius,
                  showBorder: showBorder,
                  showMinuteHand: showMinuteHand,
                  showNumber: showNumber,
                  borderWidth: borderWidth,
                  fontSize: fontSize,
                  minuteHandLength: minuteHandLength,
                  hourHandLength: hourHandLength,
                  hourNumbers: hourNumbers,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
