import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaClock extends StatelessWidget {
  final TextStyle? style;
  const AbiliaClock({
    Key? key,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.clockType != current.clockType,
        builder: (context, state) => FittedAbiliaClock(
          state.clockType,
          style: style,
        ),
      );
}

class FittedAbiliaClock extends StatelessWidget {
  final ClockType clockType;
  final double? height, width;
  final TextStyle? style;

  const FittedAbiliaClock(
    this.clockType, {
    Key? key,
    this.height,
    this.width,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return SizedBox(
      height: height ?? Lay.out.clock.height,
      width: width ?? Lay.out.clock.width,
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
