library flutter_analog_clock;

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/clock/clock_painter.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AnalogClock(
      borderWidth: layout.clock.borderWidth,
      borderColor: AbiliaColors.transparentBlack30,
      height: layout.actionButton.size,
      width: layout.actionButton.size,
      centerPointRadius: layout.clock.centerPointRadius,
      hourNumberScale: layout.clock.hourNumberScale,
      hourHandLength: layout.clock.hourHandLength,
      minuteHandLength: layout.clock.minuteHandLength,
      fontSize: layout.clock.fontSize,
    );
  }
}

class ScreensaverAnalogClock extends StatelessWidget {
  const ScreensaverAnalogClock({Key? key, required this.isNight})
      : super(key: key);
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final color = isNight ? AbiliaColors.white : AbiliaColors.black;
    return SizedBox(
      height: layout.screenSaver.clockHeight,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: _AnalogClock(
          borderWidth: 1,
          borderColor: color,
          dialPlateColor: isNight ? AbiliaColors.black : AbiliaColors.white,
          hourHandColor: color,
          minuteHandColor: color,
          numberColor: color,
          centerPointColor: color,
          height: layout.actionButton.size,
          width: layout.actionButton.size,
          centerPointRadius: layout.clock.centerPointRadius,
          hourNumberScale: layout.clock.hourNumberScale,
          hourHandLength: layout.clock.hourHandLength,
          minuteHandLength: layout.clock.minuteHandLength,
          fontSize: layout.clock.fontSize,
        ),
      ),
    );
  }
}

// A modified copy of: https://github.com/conghaonet/flutter_analog_clock
class _AnalogClock extends StatelessWidget {
  final Color dialPlateColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color centerPointColor;
  final double? centerPointRadius;
  final double? borderWidth;
  final double hourNumberScale;
  final double width;
  final double height;
  final double? fontSize;
  final double? minuteHandLength;
  final double? hourHandLength;

  const _AnalogClock({
    this.dialPlateColor = AbiliaColors.white,
    this.hourHandColor = AbiliaColors.black,
    this.minuteHandColor = AbiliaColors.black,
    this.numberColor = AbiliaColors.black,
    this.borderColor = AbiliaColors.black,
    this.centerPointColor = AbiliaColors.black,
    this.centerPointRadius,
    this.borderWidth,
    this.hourNumberScale = 1.0,
    this.fontSize,
    this.width = double.infinity,
    this.height = double.infinity,
    this.hourHandLength,
    this.minuteHandLength,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, time) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoState) => Tts.data(
          data: analogTimeStringWithInterval(
              Translator.of(context), time, memoState.dayParts),
          child: SizedBox(
            width: width,
            height: height,
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
                showBorder: true,
                showMinuteHand: true,
                showNumber: true,
                borderWidth: borderWidth,
                fontSize: fontSize,
                minuteHandLength: minuteHandLength,
                hourHandLength: hourHandLength,
                hourNumbers: ClockPainter.defaultHourNumbers,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
