// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaClock extends StatelessWidget {
  final double height, width;
  const AbiliaClock({
    Key key,
    this.height,
    this.width,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.clockType != current.clockType,
        builder: (context, state) => FittedAbiliaClock(state.clockType),
      );
}

class FittedAbiliaClock extends StatelessWidget {
  final ClockType clockType;
  final double height, width;

  const FittedAbiliaClock(
    this.clockType, {
    Key key,
    this.height,
    this.width,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return SizedBox(
      height: height ?? 60.s,
      width: width ?? 48.s,
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (analog) const AnalogClock(),
            if (digital) const DigitalClock(),
          ],
        ),
      ),
    );
  }
}
