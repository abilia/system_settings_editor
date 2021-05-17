import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AbiliaFittedColumnClock extends StatelessWidget {
  final double height, width;
  const AbiliaFittedColumnClock({Key key, this.height, this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height ?? 60.s,
        width: width ?? 48.s,
        child: FittedBox(
          child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            buildWhen: (previous, current) =>
                previous.clockType != current.clockType,
            builder: (context, state) => AbiliaColumnClock(state.clockType),
          ),
        ),
      );
}

class AbiliaColumnClock extends StatelessWidget {
  final ClockType clockType;
  const AbiliaColumnClock(
    this.clockType, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (analog) DefaultAnalogClock(),
        if (digital) const DigitalClock(),
      ],
    );
  }
}

class FittedAnalogClock extends StatelessWidget {
  final double height, width;
  const FittedAnalogClock({Key key, this.height, this.width}) : super(key: key);
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height ?? 60.s,
        width: width ?? 48.s,
        child: FittedBox(
          child: DefaultAnalogClock(),
        ),
      );
}

class AbiliaRowClock extends StatelessWidget {
  final ClockType clockType;
  const AbiliaRowClock(
    this.clockType, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final analog = clockType == ClockType.analogue ||
        clockType == ClockType.analogueDigital;
    final digital = clockType == ClockType.digital ||
        clockType == ClockType.analogueDigital;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (analog) DefaultAnalogClock(),
        if (digital) const DigitalClock(),
      ],
    );
  }
}

class DefaultAnalogClock extends StatelessWidget {
  const DefaultAnalogClock({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnalogClock(
      borderWidth: 1.0.s,
      borderColor: AbiliaColors.transparentBlack30,
      height: actionButtonMinSize,
      width: actionButtonMinSize,
      centerPointRadius: 4.0.s,
      hourNumberScale: 1.5.s,
      hourHandLength: 11.s,
      minuteHandLength: 15.s,
      fontSize: 7.s,
    );
  }
}
