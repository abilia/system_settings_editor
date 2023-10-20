import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class AbiliaClock extends StatelessWidget {
  final TextStyle? style;
  const AbiliaClock({
    super.key,
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    final clockType = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.clockType);
    return FittedAbiliaClock(clockType, style: style);
  }
}

class FittedAbiliaClock extends StatelessWidget {
  final ClockType clockType;
  final double? height, width;
  final TextStyle? style;

  const FittedAbiliaClock(
    this.clockType, {
    super.key,
    this.height,
    this.width,
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return SizedBox(
      height: height ?? layout.clock.height,
      width: width ?? layout.clock.width,
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (analog) const AnalogClock(),
            if (digital)
              DigitalClock(
                style: style,
              ),
          ],
        ),
      ),
    );
  }
}
